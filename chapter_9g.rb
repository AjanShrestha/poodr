## Testing Inherited Code ##

# You’ve finally arrived at the last challenge, testing inherited 
# code. This section is much like the previous ones in that it 
# recapitulates a previously seen example and then proceeds to test 
# it. The example used here is the final Bicycle hierarchy from 
# Chapter 6, Acquiring Behavior Through Inheritance. Even though that 
# hierarchy eventually proved unsuitable for inheritance, the 
# underlying code is fine and serves admirably as a basis for these 
# tests.

### Specifying the Inherited Interface ###
# Here’s the Bicycle class as you last saw it in Chapter 6:

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
require 'minitest/autorun'

############## Page 229 ##############
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size       = args[:size]
    @chain      = args[:chain]     || default_chain
    @tire_size  = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    { tire_size: tire_size,
      chain:     chain}.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  # subclasses may override
  def post_initialize(args)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
    '10-speed'
  end
end

# Here is the code for RoadBike, one of Bicycle’s subclasses:

############## Page 230 ##############
class RoadBike < Bicycle
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    {tape_color: tape_color}
  end

  def default_tire_size
    '23'
  end
end

############## Page ??? ##############
class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock =  args[:rear_shock]
  end

  def local_spares
    {rear_shock:  rear_shock}
  end

  def default_tire_size
    '2.1'
  end
end

# The first goal of testing is to prove that all objects in this 
# hierarchy honor their contract. The Liskov Substitution Principle 
# declares that subtypes should be substitutable for their 
# supertypes. Violations of Liskov result in unreliable objects that 
# don’t behave as expected. The easiest way to prove that every 
# object in the hierarchy obeys Liskov is to write a shared test for 
# the common contract and include this test in every object.

# The contract is embodied in a shared interface. The following test 
# articulates the interface and therefore defines what it means to be 
# a Bicycle:

############## Page 231 ##############
module BicycleInterfaceTest
  def test_responds_to_default_tire_size
    assert_respond_to(@object, :default_tire_size)
  end

  def test_responds_to_default_chain
    assert_respond_to(@object, :default_chain)
  end

  def test_responds_to_chain
    assert_respond_to(@object, :chain)
  end

  def test_responds_to_size
    assert_respond_to(@object, :size)
  end

  def test_responds_to_tire_size
    assert_respond_to(@object, :tire_size)
  end

  def test_responds_to_spares
    assert_respond_to(@object, :spares)
  end
end

# Any object that passes the BicycleInterfaceTest can be trusted to 
# act like a Bicycle. All of the classes in the Bicycle hierarchy 
# must respond to this interface and should be able to pass this 
# test. The following example includes this interface test in the 
# abstract superclass BicycleTest (line 2), and in the concrete 
# subclass RoadBikeTest (line 10):

############## Page 231 ##############
class BicycleTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest

  def setup
    @bike = @object = Bicycle.new({tire_size: 0})
  end
end

class RoadBikeTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest

  def setup
    @bike = @object = RoadBike.new
  end
end

# Running the test tells a story:
# BicycleTest
#   PASS test_responds_to_default_chain
#   PASS test_responds_to_size
#   PASS test_responds_to_tire_size
#   PASS test_responds_to_chain
#   PASS test_responds_to_spares
#   PASS test_responds_to_default_tire_size
# RoadBikeTest
#   PASS test_responds_to_chain
#   PASS test_responds_to_tire_size
#   PASS test_responds_to_default_chain 
#   PASS test_responds_to_spares
#   PASS test_responds_to_default_tire_size 
#   PASS test_responds_to_size

# The BicycleInterfaceTest will work for every kind of Bicycle and 
# can be easily included in any new subclass. It documents the 
# interface and prevents accidental regressions.

### Specifying Subclass Responsibilities ###
# Not only do all Bicycles share a common interface, the abstract 
# Bicycle superclass imposes requirements upon its subclasses.

#### Confirming Subclass Behavior ####
# Because there are many subclasses, they should share a common test 
# to prove that each meets the requirements. Here’s a test that 
# documents the requirements for subclasses:

############## Page 233 ##############
module BicycleSubclassTest
  def test_responds_to_post_initialize
    assert_respond_to(@object, :post_initialize)
  end

  def test_responds_to_local_spares
    assert_respond_to(@object, :local_spares)
  end

  def test_responds_to_default_tire_size
    assert_respond_to(@object, :default_tire_size)
  end
end

# This test codifies the requirements for subclasses of Bicycle. It 
# doesn’t force subclasses to implement these methods, in fact, any 
# subclass is free to inherit post_initialize and local_spares. This 
# test just proves that a subclass does nothing so crazy that it 
# causes these messages to fail. The only method that must be 
# implemented by subclasses is default_tire_size. The superclass 
# implementation of default_tire_size raises an error; this test will 
# fail unless the subclass implements its own specialized version.

# RoadBike acts like a Bicycle so its test already includes the 
# BicycleInterfaceTest. The test below has been changed to include 
# the new BicycleSubclassTest; RoadBike should also act like a 
# subclass of Bicycle.

############## Page 233 ##############
class RoadBikeTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest
  include BicycleSubclassTest

  def setup
    @bike = @object = RoadBike.new
  end
end

# Running this modified test tells an enhanced story:
# RoadBikeTest
#   PASS test_responds_to_default_tire_size 
#   PASS test_responds_to_spares
#   PASS test_responds_to_chain
#   PASS test_responds_to_post_initialize 
#   PASS test_responds_to_local_spares
#   PASS test_responds_to_size
#   PASS test_responds_to_tire_size 
#   PASS test_responds_to_default_chain

# Every subclass of Bicycle can share these same two modules, because 
# every subclass should act both like a Bicycle and like a subclass 
# of Bicycle. Even though it’s been a while since you’ve seen the 
# MountainBike subclass, you can surely appreciate the ability to 
# ensure that MountainBikes are good citizens by simply adding these 
# two modules to its test, as shown here:

############## Page 234 ##############
class MountainBikeTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest
  include BicycleSubclassTest

  def setup
    @bike = @object = MountainBike.new
  end
end

# The BicycleInterfaceTest and the BicycleSubclassTest, combined, 
# take all of the pain out of testing the common behavior of 
# subclasses. These tests give you confidence that subclasses aren’t 
# drifting away from the standard, and they allow novices to create 
# new subclasses in complete safety. Newly arrived programmers don’t 
# have to scour the superclasses to unearth requirements, they can 
# just include these tests when they write new subclasses.

#### Confirming Superclass Enforcement ####
# The Bicycle class should raise an error if a subclass does not 
# implement default_tire_size. Even though this requirement applies 
# to subclasses, the actual enforcement behavior is in Bicycle. This 
# test is therefore placed directly in BicycleTest, as shown on line 
# 8 below:

############## Page 235 ##############
class BicycleTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest

  def setup
    @bike = @object = Bicycle.new({tire_size: 0})
  end

  def test_forces_subclasses_to_implement_default_tire_size
    assert_raises(NotImplementedError) {@bike.default_tire_size}
  end
end

# Notice that line 5 of BicycleTest supplies a tire size, albeit an 
# odd one, at Bicycle creation time. If you look back at Bicycle’s 
# initialize method you’ll see why. The initialize method expects to 
# either receive an input value for tire_size or to be able retrieve 
# one by subsequently sending the default_tire_size message. If you 
# remove the tire_size argument from line 5, this test dies in its 
# setup method while creating a Bicycle. Without this argument, 
# Bicycle can’t successfully get through object initialization.

# The tire_size argument is necessary because Bicycle is an abstract 
# class that does not expect to receive the new message. Bicycle 
# doesn’t have a nice, friendly creation protocol. It doesn’t need 
# one because the actual application never creates instances of 
# Bicycle. However, the fact that the application doesn’t create new 
# Bicycles doesn’t mean this never happens. It surely does. Line 5 of 
# the BicycleTest above clearly creates a new instance of this 
# abstract class.

# This problem is ubiquitous when testing abstract classes. The 
# BicycleTest needs an object on which to run tests and the most 
# obvious candidate is an instance of Bicycle. However, creating a 
# new instance of an abstract class can range from difficult and 
# impossible. This test is fortunate in that Bicycle’s creation 
# protocol allows the test to create a concrete Bicycle instance by 
# passing tire_size, but creating a testable object is not always 
# this easy and you may find it necessary to employ a more 
# sophisticated strategy. Fortunately, there’s an easy way to 
# overcome this general problem that will be covered below in the 
# section Testing Abstract Superclass Behavior.

# For now, supplying the tire_size argument works just fine. Running 
# BicycleTest now produces output that looks more like that of an 
# abstract superclass:
# BicycleTest
#   PASS test_responds_to_default_tire_size 
#   PASS test_responds_to_size
#   PASS test_responds_to_default_chain 
#   PASS test_responds_to_tire_size 
#   PASS test_responds_to_chain
#   PASS test_responds_to_spares
#   PASS test_forces_subclasses_to_implement_default_tire_size