## Testing Duck Types ##
# The Testing Incoming Messages section in this chapter wandered into 
# the territory of testing roles, but while it introduced the issue, 
# it did not provide a satisfactory resolution. It’s time to return 
# to that topic and examine how to test duck types. This section 
# shows how to create tests that role players can share and then 
# returns to the original problem and uses shareable tests to prevent 
# test doubles from becoming obsolete.

## Testing Roles ##
# The code for this first example comes from the Preparer duck type 
# of Chapter 5, Reducing Costs with Duck Typing. These first few code 
# samples repeat part of the lesson from Chapter 5; feel free to skim 
# down to the first test if you have a clear memory of the problem.

# Here’s a reminder of the original Mechanic, TripCoordinator, and 
# Driver classes:

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
require 'minitest/autorun'

############## Page 219 ##############
class Mechanic
  def prepare_bicycle(bicycle)
    #...
  end
end

class TripCoordinator
  def buy_food(customers)
    #...
  end
end

class Driver
  def gas_up(vehicle)
    #...
  end
  def fill_water_tank(vehicle)
    #...
  end
end

# Each of these classes has a reasonable public interface, yet when 
# Trip used these interfaces to prepare a trip it was forced to check 
# the class of each object to determine which message to send, as 
# shown here:

############## Page 220 ##############
# The full class is below.
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.gas_up(vehicle)
        preparer.fill_water_tank(vehicle)
      end
    }
  end
end

############## Full example, so tests will run.
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def initialize(args={})
    @bicycles  = args[:bicycles]  ||= []
    @customers = args[:customers] ||= []
    @vehicles  = args[:vehicle]
  end

  def prepare(preparers)
    preparers.each {|preparer|
      preparer.prepare_trip(self)}
  end
end


# The case statement above couples prepare to three existing concrete 
# classes. Imagine trying to test the prepare method or the 
# consequences of adding a new kind of preparer into this mix. This 
# method is painful to test and expensive to maintain.

# If you come upon code that uses this antipattern but does not have 
# tests, consider refactoring to a better design before writing them. 
# It’s always dangerous to make changes in the absence of tests, but 
# this teetering pile of code is so fragile that refactoring it first 
# might well be the most cost-effective strategy. The refactoring 
# that fixes this problem is simple and makes all subsequent change 
# easier.

# The first part of the refactoring is to decide on Preparer’s 
# interface and to implement that interface in every player of the 
# role. If the public interface of Preparer is prepare_trip, the 
# following changes allow Mechanic, TripCoordinator, and Driver to 
# play the role:

############## Page 220 ##############
class Mechanic
  def prepare_trip(trip)
    trip.bicycles.each {|bicycle|
      prepare_bicycle(bicycle)}
  end

  # ...
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end

  # ...
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up(vehicle)
    fill_water_tank(vehicle)
  end
  # ...
end

# Now that Preparers exist, Trip’s prepare method can be vastly 
# simplified. The following refactoring alters Trip’s prepare method 
# to collaborate with Preparers instead of sending unique messages to 
# each specific class:

############## Page 221 ##############
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      preparer.prepare_trip(self)}
  end
end

# Having done these refactorings you are positioned to write tests. 
# The above code contains a collaboration between Preparers and a 
# Trip, which can now be thought of as a Preparable. Your tests 
# should document the existence of the Preparer role, prove that each 
# of its players behaves correctly, and show that Trip interacts with 
# them appropriately.

# Because several different classes act as Preparers, the role’s test 
# should be written once and shared by every player. MiniTest is a 
# low ceremony testing framework and it supports sharing tests in the 
# simplest possible way, via Ruby modules.

# Here’s a module that tests and documents the Preparer interface:

############## Page 222 ##############
module PreparerInterfaceTest
  def test_implements_the_preparer_interface
    assert_respond_to(@object, :prepare_trip)
  end
end

# This module proves that @object responds to prepare_trip. The test 
# below uses this module to prove that Mechanic is a Preparer. It 
# includes the module (line 2) and provides a Mechanic during setup 
# via the @object variable (line 5).

############## Page 222 ##############
class MechanicTest < MiniTest::Unit::TestCase
  include PreparerInterfaceTest

  def setup
    @mechanic = @object = Mechanic.new
  end

  # other tests which rely on @mechanic
end

# The TripCoordinator and Driver tests follow this same pattern. They 
# also include the module (lines 2 and 10 below) and initialize 
# @object in their setup methods (lines 5 and 13).

############## Page 222 ##############
class TripCoordinatorTest < MiniTest::Unit::TestCase
  include PreparerInterfaceTest

  def setup
    @trip_coordinator = @object = TripCoordinator.new
  end
end

class DriverTest < MiniTest::Unit::TestCase
  include PreparerInterfaceTest

  def setup
    @driver = @object =  Driver.new
  end
end

# Running these three tests produces a satisfying result:
# DriverTest
#   PASS test_implements_the_preparer_interface 
# MechanicTest
#   PASS test_implements_the_preparer_interface 
# TripCoordinatorTest
#   PASS test_implements_the_preparer_interface

# Defining the PreparerInterfaceTest as a module allows you to write 
# the test once and then reuse it in every object that plays the 
# role. The module serves as a test and as documentation. It raises 
# the visibility of the role and makes it easy to prove that any 
# newly created Preparer successfully fulfills its obligations.

# The test_implements_the_preparer_interface method tests an incoming 
# message and as such belongs with the receiving object’s tests, 
# which is why the module gets included in the tests of Mechanic, 
# TripCoordinator, and Driver. Incoming messages, however, go 
# hand-in-hand with outgoing messages and you must test both sides of 
# this equation. You have proven that all receivers correctly 
# implement prepare_trip, now you must also prove that Trip correctly 
# sends it.

# As you know, proving that an outgoing message gets sent is done by 
# setting expectations on a mock. The following test creates a mock 
# (line 4), tells it to expect prepare_trip (line 6), triggers Trip’s 
# prepare method (line 8), and then verifies that the mock received 
# the proper message (line 9).

############## Page 223 ##############
class TripTest < MiniTest::Unit::TestCase

  def test_requests_trip_preparation
    @preparer = MiniTest::Mock.new
    @trip     = Trip.new
    @preparer.expect(:prepare_trip, nil, [@trip])

    @trip.prepare([@preparer])
    @preparer.verify
  end
end

# The test_requests_trip_preparation test lives directly in TripTest. 
# Trip is the only Preparable in the application so there’s no other 
# object with which to share this test. If other Preparables arise 
# the test should be extracted into a module and shared among 
# Preparables at that time.

# Running this test proves that Trip collaborates with Preparers 
# using the correct interface:
# TripTest
#   PASS test_requests_trip_preparation

# This completes the tests of the Preparer role. It’s now possible to 
# return to the problem of brittleness when using doubles to play 
# roles in tests.
