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

### Testing Unique Behavior ###
# The inheritance tests have so far concentrated on testing common 
# qualities. Most of the resulting tests were shareable and ended up 
# being placed in modules (BicycleInterfaceTest and 
# BicycleSubclassTest), although one test 
# (forces_subclasses_to_implement_default_tire_size) did get placed 
# directly into BicycleTest.

# Now that you have dispensed with the common behavior, two gaps 
# remain. There are as yet no tests for specializations, neither for 
# the ones provided by the concrete subclasses nor for those defined 
# in the abstract superclass. The following section concentrates on 
# the first; it tests specializations supplied by individual 
# subclasses. The section after moves the focus upward in the 
# hierarchy and tests behavior that is unique to Bicycle.

#### Testing Concrete Subclass Behavior ####
# Now is the time to renew your commitment to writing the absolute 
# minimum number of tests. Look back at the RoadBike class. The 
# shared modules already prove most of its behavior. The only thing 
# left to test are the specializations that RoadBike supplies.

# It’s important to test these specializations without embedding 
# knowledge of the superclass into the test. For example, RoadBike 
# implements local_spares and also responds to spares. The 
# RoadBikeTest should ensure that local_spares works while 
# maintaining deliberate ignorance about the existence of the spares 
# method. The shared BicycleInterfaceTest already proves that 
# RoadBike responds correctly to spares, it is redundant and 
# ultimately limiting to reference that method directly in this test.

# The local_spares method, however, is clearly RoadBike’s 
# responsibility. Line 9 below tests this specialization directly in 
# RoadBikeTest:

############## Page 236 ##############
class RoadBikeTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest
  include BicycleSubclassTest

  def setup
    @bike = @object = RoadBike.new(tape_color: 'red')
  end

  def test_puts_tape_color_in_local_spares
    assert_equal 'red', @bike.local_spares[:tape_color]
  end
end

# Running RoadBikeTest now shows that it meets its common 
# responsibilities and also supplies its own specializations:
# RoadBikeTest
#   PASS test_responds_to_default_chain
#   PASS test_responds_to_default_tire_size 
#   PASS test_puts_tape_color_in_local_spares 
#   PASS test_responds_to_spares
#   PASS test_responds_to_size
#   PASS test_responds_to_local_spares
#   PASS test_responds_to_post_initialize 
#   PASS test_responds_to_tire_size
#   PASS test_responds_to_chain

#### Testing Abstract Superclass Behavior ####
# Now that you have tested the subclass specializations it’s time to 
# step back and finish testing the superclass. Moving your focus up 
# the hierarchy to Bicycle reintroduces a previously encountered 
# problem; Bicycle is an abstract superclass. Creating an instance of 
# Bicycle is not only hard but the instance might not have all the 
# behavior you need to make the test run.

# Fortunately, your design skills provide a solution. Because Bicycle 
# used template methods to acquire concrete specializations you can 
# stub the behavior that would normally be supplied by subclasses. 
# Even better, because you understand the Liskov Substitution 
# Principle, you can easily manufacture a testable instance of 
# Bicycle by creating a new subclass for use solely by this test.

# The test below follows just such a strategy. Line 1 defines a new 
# class, StubbedBike, as a subclass of Bicycle. The test creates an 
# instance of this class (line 15) and uses it to prove that Bicycle 
# correctly includes the subclass’s local_spares contribution in 
# spares (line 23).

# It remains convenient to sometimes create an instance of the 
# abstract Bicycle class, even though this requires passing the 
# tire_size argument, as on line 14. This instance of Bicycle 
# continues to be used in the test on line 18 to prove that the 
# abstract class forces subclasses to implement default_tire_size.

# These two kinds of Bicycles coexist peacefully in the test, as you see here:

############## Page 238 ##############
class StubbedBike < Bicycle
  def default_tire_size
    0
  end
  def local_spares
    {saddle: 'painful'}
  end
end

class BicycleTest < MiniTest::Unit::TestCase
  include BicycleInterfaceTest

  def setup
    @bike = @object = Bicycle.new({tire_size: 0})
    @stubbed_bike   = StubbedBike.new
  end

  def test_forces_subclasses_to_implement_default_tire_size
    assert_raises(NotImplementedError) {
      @bike.default_tire_size}
  end

  def test_includes_local_spares_in_spares
    assert_equal @stubbed_bike.spares,
                  { tire_size: 0,
                    chain:     '10-speed',
                    saddle:    'painful'}
  end
end

# The idea of creating a subclass to supply stubs can be helpful in 
# many situations. As long as your new subclass does not violate 
# Liskov, you can use this technique in any test you like.

# Running BicycleTest now proves that it includes subclass 
# contributions on the spares list:
# BicycleTest
#   PASS test_responds_to_spares 
#   PASS test_responds_to_tire_size
#   PASS test_responds_to_default_chain
#   PASS test_responds_to_default_tire_size
#   PASS test_forces_subclasses_to_implement_default_tire_size 
#   PASS test_responds_to_chain
#   PASS test_includes_local_spares_in_spares
#   PASS test_responds_to_size

# One last point: If you fear that StubbedBike will become obsolete 
# and permit BicycleTest to pass when it should fail, the solution is 
# close at hand. There is already a common BicycleSubclassTest. Just 
# as you used the Diameterizable InterfaceTest to guarantee 
# DiameterDouble’s continued good behavior, you can use 
# BicycleSubclassTest to ensure the ongoing correctness of 
# StubbedBike. Add the following code to BicycleTest:

############## Page 239 ##############
class StubbedBikeTest < MiniTest::Unit::TestCase
  include BicycleSubclassTest

  def setup
    @object = StubbedBike.new
  end
end

# After you make this change, running BicycleTest produces this 
# additional output:
# StubbedBikeTest
#   PASS test_responds_to_default_tire_size 
#   PASS test_responds_to_local_spares
#   PASS test_responds_to_post_initialize

# Carefully written inheritance hierarchies are easy to test. Write 
# one shareable test for the overall interface and another for the 
# subclass responsibilities. Diligently isolate responsibilities. Be 
# especially careful when testing subclass specializations to prevent 
# knowledge of the superclass from leaking down into the subclass’s 
# test.

# Testing abstract superclasses can be challenging; use the Liskov 
# Substitution Principle to your advantage. If you leverage Liskov 
# and create new subclasses that are used exclusively for testing, 
# consider requiring these subclasses to pass your subclass 
# responsibility test to ensure they don’t accidentally become 
# obsolete.

## Summary ##
# Tests are indispensable. Well-designed applications are highly 
# abstract and under constant pressure to evolve; without tests these 
# applications can neither be understood nor safely changed. The best 
# tests are loosely coupled to the underlying code and test 
# everything once and in the proper place. They add value without 
# increasing costs.

# A well-designed application with a carefully crafted test suite is 
# a joy to behold and a pleasure to extend. It can adapt to every new 
# circumstance and meet any unexpected need.