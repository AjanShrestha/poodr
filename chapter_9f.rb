### Using Role Tests to Validate Doubles ###

# Now that you know how to write reusable tests that prove an object 
# correctly plays a role you can use this technique to reduce the 
# brittleness caused by stubbing.

# The earlier section, Testing Incoming Messages, introduced the 
# “living the dream” problem. The final test in that section 
# contained a misleading false positive, in which a test that should 
# have failed instead passed because of a test double that stubbed an 
# obsolete method. Here’s a reminder of that faultily passing test:

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
require 'minitest/autorun'

############## Page ??? ##############
class Wheel
  attr_reader :rim, :tire
  def initialize(rim, tire)
    @rim       = rim
    @tire      = tire
  end

  def width   # <---- used to be 'diameter'
    rim + (tire * 2)
  end
# ...
end

############## Page ??? ##############
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def ratio
    chainring / cog.to_f
  end
# ...
end

############## Page ??? ##############
class Gear
  # ...
  def gear_inches
    ratio * wheel.diameter # <--- obsolete
  end
end

############## Page 224 ##############
class DiameterDouble

  def diameter  # The interface changed to 'width',
    10          # but this double and Gear both
  end           # still use 'diameter'.
end

class GearTest < MiniTest::Unit::TestCase
  def test_calculates_gear_inches
    gear =  Gear.new(
              chainring: 52,
              cog:       11,
              wheel:     DiameterDouble.new)

    assert_in_delta(47.27,
                    gear.gear_inches,
                    0.01)
  end
end

# The problem with this test is that DiameterDouble purports to play 
# the Diameterizable role but it does so incorrectly. Now that 
# Diameterizable’s interface has changed DiameterDouble is 
# out-of-date. This obsolete double enables the test to bumble along 
# in the mistaken belief that Gear works correctly, when in actual 
# fact GearTest only works when combined with its similarly confused 
# test double. The application is broken but you cannot tell it by 
# running this test.

# You last saw WheelTest in the Using Tests to Document Roles 
# section, where it was attempting to counter this problem by raising 
# the visibility of Diameterizable’s interface. Here’s an example 
# where line 6 proves that Wheel acts like a Diameterizable that 
# implements width:

############## Page 225 ##############
class WheelTest < MiniTest::Unit::TestCase
  def setup
    @wheel = Wheel.new(26, 1.5)
  end

  def test_implements_the_diameterizable_interface
    assert_respond_to(@wheel, :width)
  end

  def test_calculates_diameter
    # ...
  end
end

# With this test, you now hold all the pieces needed to solve the 
# brittleness problem. You know how to share tests among players of a 
# role, you recognize that you have two players of the Diameterizable 
# role, and you have a test that any object can use to prove that it 
# correctly plays the role.

# The first step in solving the problem is to extract 
# test_implements_the_diameterizable_interface from Wheel into a 
# module of its own:

############## Page 226 ##############
module DiameterizableInterfaceTest
  def test_implements_the_diameterizable_interface
    assert_respond_to(@object, :width)
  end
end

# Once this module exists, reintroducing the extracted behavior back 
# into WheelTest is a simple matter of including the module (line 2) 
# and initializing @object with a Wheel (line 5):

############## Page 226 ##############
class WheelTest < MiniTest::Unit::TestCase
  include DiameterizableInterfaceTest

  def setup
    @wheel = @object = Wheel.new(26, 1.5)
  end

  def test_calculates_diameter
    # ...
  end
end

# At this point WheelTest works just as it did before the extraction, 
# as you can see by running the test:
# WheelTest
#   PASS test_implements_the_diameterizable_interface 
#   PASS test_calculates_diameter

# It’s gratifying that the WheelTest still passes but this 
# refactoring serves a broader purpose than that of merely 
# rearranging the code. Now that you have an independent module that 
# proves that a Diameterizable behaves correctly, you can use the 
# module to prevent test doubles from silently becoming obsolete.

# The GearTest below has been updated to use this new module. Lines 9 
# through 15 define a new test class, DiameterDoubleTest. 
# DiameterDoubleTest is not about Gear per se, its purpose is to 
# prevent test brittleness by ensuring the ongoing soundness of the 
# double.

############## Page 227 ##############
class DiameterDouble
  def diameter
    10
  end
end

# Prove the test double honors the interface this
#   test expects.
class DiameterDoubleTest < MiniTest::Unit::TestCase
  include DiameterizableInterfaceTest

  def setup
    @object = DiameterDouble.new
  end
end

class GearTest < MiniTest::Unit::TestCase
  def test_calculates_gear_inches
    gear =  Gear.new(
              chainring: 52,
              cog:       11,
              wheel:     DiameterDouble.new)

    assert_in_delta(47.27,
                    gear.gear_inches,
                    0.01)
  end
end

# The fact that DiameterDouble and Gear are both incorrect has been 
# allowing previous versions of this test to pass. Now that the 
# double is being tested to ensure it honestly plays its role, 
# running the test finally produces an error:
# DiameterDoubleTest
#   FAIL test_implements_the_diameterizable_interface
#     Expected #<DiameterDouble:...> (DiameterDouble)
#       to respond to #width. 
#   GearTest
#     PASS test_calculates_gear_inches

# The GearTest still passes erroneously but that’s not a problem 
# because DiameterDoubleTest now informs you that DiameterDouble is 
# wrong. This failure causes you to correct DiameterDouble to 
# implement width, as shown on line 2 below:

############## Page 228 ##############
# Full example is below.
class DiameterDouble
  def width
    10
  end
end

############## Full example, so tests will run.
class DiameterDouble
  def width
    10
  end
end

class DiameterDoubleTest < MiniTest::Unit::TestCase
  include DiameterizableInterfaceTest

  def setup
    @object = DiameterDouble.new
  end
end

class GearTest < MiniTest::Unit::TestCase
  def test_calculates_gear_inches
    gear =  Gear.new(
              chainring: 52,
              cog:       11,
              wheel:     DiameterDouble.new)

    assert_in_delta(47.27,
                    gear.gear_inches,
                    0.01)
  end
end

# After this change, re-running the test produces a failure in GearTest: 
# DiameterDoubleTest
#   PASS test_implements_the_diameterizable_interface
# GearTest
#   ERROR test_calculates_gear_inches
#     undefined method 'diameter'
#       for #<DiameterDouble:0x0000010090a7f8>
#         gear_test.rb:35:in 'gear_inches'
#           gear_test.rb:86:in 'test_calculates_gear_inches'

# Now that DiameterDoubleTest passes, GearTest fails. This failure 
# points directly to the offending line of code in Gear. The tests 
# finally tell you to change Gear’s gear_inches method to send width 
# instead of diameter, as in this example:

############## Page 228 ##############
# Full listing is below
class Gear

  def gear_inches
    # finally, 'width' instead of 'diameter'
    ratio * wheel.width
  end

# ...
end

############## Page ??? ##############
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end

  def gear_inches
    ratio * wheel.width
  end

  def ratio
    chainring / cog.to_f
  end
# ...
end

# Once you make this final change, the application is correct and all 
# tests correctly pass:
# DiameterDoubleTest
#   PASS test_implements_the_diameterizable_interface
# GearTest
#   PASS test_calculates_gear_inches

# Not only does this test pass, but it will continue to pass (or 
# fail) appropriately, no matter what happens to the Diameterizable 
# interface. When you treat test doubles as you would any other role 
# player and test them to prove their correctness, you avoid test 
# brittleness and can stub without fear of consequence.

# The desire to test duck types creates a need for shareable tests 
# for roles, and once you acquire this role-based perspective you can 
# use it to your advantage in many situations. From the point of view 
# of the object under test, every other object is a role and dealing 
# with objects as if they are representatives of the roles they play 
# loosens coupling and increases flexibility, both in your 
# application and in your tests.