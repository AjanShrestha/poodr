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