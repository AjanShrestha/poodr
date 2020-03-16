### Isolation the Object Under Test ###
# Gear is a simple object but attempts to test its gear_inches method 
# have already unearthed hidden complexity. The goal of this test is 
# to ensure that gear inches are calculated correctly but it turns 
# out that running gear_inches relies on code in objects other than 
# Gear.
# This exposes a broader design problem; when you can’t test Gear in 
# isolation, it bodes ill for the future. This difficulty in 
# isolating Gear for testing reveals that it is bound to a specific 
# context, one that imposes limitations that will interfere with 
# reuse.

# Chapter 3 broke this binding by removing the creation of Wheel from 
# Gear. Here’s a copy of the code that made that transition; Gear now 
# expects to be injected with an object that understands diameter.

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
require 'minitest/autorun'

############## Page ??? ##############
# The Wheel class expected by the following test
class Wheel
  attr_reader :rim, :tire
  def initialize(rim, tire)
    @rim       = rim
    @tire      = tire
  end

  def diameter
    rim + (tire * 2)
  end
# ...
end

############## Page 205 ##############
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end

  def gear_inches
      # The object in the 'wheel' variable
      #   plays the 'Diameterizable' role.
    ratio * wheel.diameter
  end

  def ratio
    chainring / cog.to_f
  end
# ...
end

# This transition of code is paralleled by a transition of thought. 
# Gear no longer cares about the class of the injected object, it 
# merely expects that it implement diameter. The diameter method is 
# part of the public interface of a role, one that might reasonably 
# be named Diameterizable.

# Now that Gear is decoupled from Wheel, you must inject an instance 
# of Diameterizable during every Gear creation. However, because 
# Wheel is the only application class that plays this role, your 
# runtime options are severely limited. In real life, as the code 
# currently exists, every Gear that you create will of necessity be 
# injected with an instance of Wheel.

# **
# As circular as this sounds, injecting a Wheel into Gear is not the 
# same as injecting a Diameterizable. The application code looks 
# exactly the same, granted, but its logical meaning differs. The 
# difference is not in the characters that you type but in your 
# thoughts about what they mean. Freeing your imagination from an 
# attachment to the class of the incoming object opens design and 
# testing possibilities that are otherwise unavailable. Thinking of 
# the injected object as an instance of its role gives you more 
# choices about what kind of Diameterizable to inject into Gear 
# during your tests.
# One possible Diameterizable is, obviously, Wheel, because it 
# clearly implements the correct interface. The next example makes 
# this very prosaic choice; it updates the existing test to 
# accommodate the changes to the code by injecting an instance of 
# Wheel (line 6) during the test.

############## Page 206 ##############
class GearTest < MiniTest::Unit::TestCase
  def test_calculates_gear_inches
    gear =  Gear.new(
              chainring: 52,
              cog:       11,
              wheel:     Wheel.new(26, 1.5))

    assert_in_delta(137.1,
                    gear.gear_inches,
                    0.01)
  end
end

# Using a Wheel for the injected Diameterizable results in test code 
# that exactly mirrors the application. It is now obvious, both in 
# the application and in the tests, that Gear is using Wheel. The 
# invisible coupling between these classes has been publicly exposed.

# This test is fast enough but this adequate speed is quite by 
# accident. It’s not that the gear_inches test has been carefully 
# isolated and thus decoupled from other code; not at all, it’s just 
# that all the code coupled to this test runs quickly as well.

# Notice also that it’s not obvious here (or anywhere else for that 
# matter) that Wheel is playing the Diameterizable role. The role is 
# virtual, it’s all in your head. Nothing about the code guides 
# future maintainers to think of Wheel as a Diameterizable.
# However, despite the invisibility of the role and this coupling to 
# Wheel, structuring the test in this way has one very real advantage.