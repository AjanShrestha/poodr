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

### Injecting Dependencies Using Classes ###
# When the code in your test uses the same collaborating objects as 
# the code in your application, your tests always break when they 
# should. The value of this cannot be underestimated.

# Here’s a simple example. Imagine that Diameterizable’s public 
# interface changes. Another programmer goes into the Wheel class and 
# changes the diameter method’s name to width, as shown in line 8 
# below.

############## Page 207 ##############
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

# Imagine further that this programmer failed to update the name of 
# the sent message in Gear. Gear still sends diameter in its 
# gear_inches method, as you can see in this reminder of Gear’s 
# current code:

############## Page 207 ##############
class Gear
  # ...
  def gear_inches
    ratio * wheel.diameter # <--- obsolete
  end
end

############## Page ?? ##############
# Full listing for above
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

# Because the Gear test injects an instance of Wheel and Wheel 
# implements width but Gear sends diameter, the test now fails:
#   Gear
#     ERROR test_calculates_gear_inches
#           undefined method 'diameter'

# This failure is unsurprising, it is exactly what should happen when 
# two concrete objects collaborate and the receiver of a message 
# changes but its sender does not. Wheel has changed and as a result 
# Gear needs to change. This test fails as it should.

# The test is simple and the failure obvious because the code is so 
# concrete, but like all concretions it works only for this specific 
# case. Here, for this code, the test above is good enough, but there 
# are other situations in which you are better served to locate and 
# test the abstraction.

# **
# A more extreme example illuminates the problem. If there are 
# hundreds of Diameterizables, how do you decide which is most 
# intention revealing to inject during the test? What if 
# Diameterizables are extremely costly, how do you avoid running lots 
# of unnecessary, time-consuming code? Common sense suggests that if 
# Wheel is the only Diameterizable and it is fast enough, the test 
# should just inject a Wheel, but what if your choice is less obvious?

### Injecting Dependencies as Roles ###
# The Wheel class and the Diameterizable role are so closely aligned 
# that it’s hard to see them as separate concepts, but understanding 
# what happened in the previous test requires making a distinction. 
# Gear and Wheel both have relationships with a third thing, the 
# Diameterizable role. As you can see in Figure 9.4, Diameterizable 
# is depended on by Gear and implemented by Wheel.

# This role is an abstraction of the idea that disparate objects can 
# have diameters. As with all abstractions, it is reasonable to 
# expect this abstract role to be more stable than the concretion 
# from which it came. However in the specific case above the opposite 
# is true.
# There are two places in the code where an object depends on 
# knowledge of Diameterizable. 
#   First, Gear thinks that it knows Diameterizable’s interface; that 
#     is, it believes it can send diameter to the injected object. 
#   Second, the code that created the object to be injected believes 
#     that Wheel implements this interface; that is, it expects Wheel 
#     to implement diameter. 
# Now that Diameterizable has changed, there’s a problem. Wheel has 
# been updated to implement the new interface but unfortunately 
# Gear still expects the old one.

# **
# The whole point of dependency injection is that it allows you to 
# substitute different concrete classes without changing existing 
# code. You can assemble new behavior by creating new objects that 
# play existing roles and injecting these objects where those roles 
# are expected. Object-oriented design tells you to inject 
# dependencies because it believes that specific concrete classes 
# will vary more than these roles, or conversely, roles will be more 
# stable than the classes from which they were abstracted.
# Unfortunately, the opposite just happened. In this example it was 
# not the class of the injected object that changed, it was the 
# interface of the role. It is still correct to inject a Wheel but 
# now incorrect to send that Wheel the diameter message.

# **
# When a role has a single player, that one concrete player and the 
# abstract role are so closely aligned that the boundaries between 
# them are easily blurred and it is a practical fact that sometimes 
# this blurring doesn’t matter. In this case Wheel is the only player 
# of Diameterizable and you don’t currently expect to have others. If 
# Wheels are cheap, injecting an actual Wheel has little negative 
# effect on your tests.
# When the application code can only be written one way, mirroring 
# that arrangement is often the most effective way to write tests. 
# Doing so permits tests to correctly fail regardless of whether the 
# concretion (the name of the Wheel class) or the abstraction (the 
# interface to the diameter method) changes.

# However, this is not always true. Sometimes there are forces at 
# work that drive you to wish to forgo the use of Wheel in your 
# tests. If your application contains many different Diameterizables 
# you might want to create an idealized one so your tests clearly 
# convey the idea of this role. If all Diameterizables are expensive, 
# you may want to fake a cheap one to make your tests run faster. If 
# you are doing BDD, your application might not yet contain any 
# object that plays this role; you may be forced to manufacture 
# something just to write the test.

#### Creating Test Doubles ####
# This next example explores the idea of creating a fake object, or 
# test double, to play the Diameterizable role. For this test, assume 
# Diameterizable’s interface has reverted to the original diameter 
# method and that diameter is again correctly implemented by Wheel 
# and sent by Gear. Line 2 below creates a fake, DiameterDouble. Line 
# 13 injects this fake into Gear.

############## Page 210 ##############
# Create a player of the 'Diameterizable' role
class Diameterizable
  def diameter
    10
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

# A test double is a stylized instance of a role player that is used 
# exclusively for testing. Doubles like this are very easy to make; 
# nothing hinders you from creating one for every possible situation. 
# Each variation is like an artist’s sketch. It emphasizes a single 
# interesting feature and allows the underlying object’s other 
# details to recede to the background.
# This double stubs diameter, that is, it implements a version of 
# diameter that returns a canned answer. DiameterDouble is quite 
# limited, but that’s the whole point. The fact that it always 
# returns 10 for diameter is perfect. This stubbed return value 
# provides a dependable foundation on which to construct the test.

# Many test frameworks have built-in ways to create doubles and to 
# stub return values. These specialized mechanisms can be handy, but 
# for simple test doubles it’s fine to use plain old Ruby objects, as 
# does the example above.

# DiameterDouble is not a mock. It’s easy to slip into the habit of 
# using the word “mock” to describe this double, but mocks are 
# something else entirely.

# Injecting this double decouples the Gear test from the Wheel class. 
# It no longer matters if Wheel is slow because DiameterDouble is 
# always fast. This test works just fine, as running it shows:
# GearTest
#    PASS test_calculates_gear_inches

# This test uses a test double and is therefore simple, fast, 
# isolated, and intention reveal-ing; what could possibly go wrong?

#### Living the Dream ####
# Imagine now that the code undergoes the same alterations as before: 
# Diameterizable’s interface changes from diameter to width and Wheel 
# gets updated but Gear does not. This change once again breaks the 
# application. Remember that the previous Gear test (which injected a 
# Wheel instead of using a double) noticed this problem right away 
# and began to fail with an undefined method ‘diameter’ error.

# Now that you’re injecting DiameterDouble, however, here’s what 
# happens when you re-run the test:
# GearTest
#     PASS test_calculates_gear_inches

# **
# The test continues to pass even though the application is 
# definitely broken. This application cannot possibly work; Gear 
# sends diameter but Wheel implements width.
# You have created an alternate universe, one in which tests 
# cheerfully report that all is well despite the fact that the 
# application is manifestly incorrect. The possibility of creating 
# this universe is what causes some to warn that stubbing (and 
# mocking) makes for brittle tests. However, as is always true, the 
# fault here is with the programmer, not the tool. Writing better 
# code requires understanding the root cause of this problem, which 
# in turn necessitates a closer look at its components.

# The application contains a Diameterizable role. This role 
# originally had one player, Wheel. When GearTest created 
# DiameterDouble, it introduced a second player of the role. When the 
# interface of a role changes, all players of the role must adopt the 
# new interface. It’s easy, however, to overlook role players that 
# were constructed specifically for tests and that is exactly what 
# happened here. Wheel got updated with the new interface but 
# DiameterDouble did not.

#### Using Test to Document Roles ####
# It’s no wonder this problem occurs; the role is nearly invisible. 
# There’s no place in the application where you can point your finger 
# and say “This defines Diameterizable.” When remembering that the 
# role even exists is a challenge, forgetting that test doubles play 
# it is inevitable.

# One way to raise the role’s visibility is to assert that Wheel 
# plays it. Line 6 below does just this; it documents the role and 
# proves that Wheel correctly implements its interface.

############## Page 212 ##############
class WheelTest < MiniTest::Unit::TestCase
  def setup
    @wheel = Wheel.new(26, 1.5)
  end

  def test_implements_the_diameterizable_interface
    assert_respond_to(@wheel, :diameter)
  end

  def test_calculates_diameter
    wheel = Wheel.new(26, 1.5)

    assert_in_delta(29,
                    wheel.diameter,
                    0.01)
  end
end

# The implements_the_diameterizable_interface test introduces the 
# idea of tests for roles but is not a completely satisfactory 
# solution. It is, in fact, woefully incomplete. 
#   First, it cannot be shared with other Diameterizables. Other  
#     players of this role would have to duplicate this test. 
#   Next, it does nothing to help with the “living the dream” problem 
#     from the Gear test. Wheel’s assertion that it plays this role 
#     does not prevent Gear’s DiameterDouble from becoming obsolete 
#     and allowing the gear_inches test to erroneously pass.

# Fortunately, the problem of documenting and testing roles has a 
# simple solution, Proving the Correctness of Ducks. For now it’s 
# enough to recognize that roles need tests of their own.

# The goal of this section was to prove public interfaces by testing 
# incoming messages. Wheel was cheap to test. The original Gear test 
# was more expensive because it depended on a hidden coupling to 
# Wheel. Replacing that coupling with an injected dependency on 
# Diameterizable isolated the object under test but created a dilemma 
# about whether to inject a real or a fake object.

# This choice between injecting real or fake objects has far-reaching 
# consequences. Injecting the same objects at test time as are used 
# at runtime ensures that tests break correctly but may lead to long 
# running tests. Alternatively, injecting doubles can speed tests but 
# leave them vulnerable to constructing a fantasy world where tests 
# work but the application fails.

# Notice that the act of testing did not, by itself, force an 
# improvement in design. Nothing about testing made you remove the 
# coupling and inject the dependency. While it’s true that the 
# outside-in approach of BDD provides more guidance than does TDD, 
# neither practice prevents a naïve designer from writing Wheel and 
# then embedding the creation of a Wheel deep inside of Gear. This 
# coupling doesn’t make tests impossible, it just raises costs. 
# Reducing the coupling is up to you and relies on your understanding 
# of the principles of design.