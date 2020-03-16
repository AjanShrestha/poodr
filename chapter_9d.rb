## Testing Outgoing Messages ##
# Outgoing messages, as you know from the “What to Test” section, are 
# either queries or commands. Query messages matter only to the 
# object that sends them, while command messages have effects that 
# are visible to other objects in your application.

### Ignoring Query Messages ###
# Messages that have no side effects are known as query messages. 
# Here’s a simple example, where Gear’s gear_inches method sends 
# diameter.

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new
require 'minitest/autorun'

############## Page 215 ##############
class Gear
  # ...
  def gear_inches
    ratio * wheel.diameter
  end
end

# Nothing in the application other than the gear_inches method cares 
# that diameter gets sent. The diameter method has no side effects, 
# running it leaves no visible trace, and no other objects depend on 
# its execution.

# In the same way that tests should ignore messages sent to self, 
# they also should ignore outgoing query messages. The consequences 
# of sending diameter are hidden inside of Gear. Because the overall 
# application does not need this message to be sent, your tests need 
# not care.

# Gear’s gear_inches method depends on the result that diameter 
# returns, but tests to prove the correctness of diameter belong in 
# Wheel, not here in Gear. It is redundant for Gear to duplicate 
# those tests, maintenance costs will increase if it does. Gear’s 
# only responsibility is to prove that gear_inches works correctly 
# and it can do this by simply testing that gear_inches always 
# returns appropriate results.

# **
### Proving Command Messages ##
# Sometimes, however, it does matter that a message get sent; other 
# parts of your application depend on something that happens as a 
# result. In this case the object under test is responsible for 
# sending the message and your tests must prove it does so.

# Illustrating this problem requires a new example. Imagine a game 
# where players race virtual bicycles. These bicycles, obviously, 
# have gears. The Gear class is now responsible for letting the 
# application know when a player changes gears so the application can 
# update the bicycle’s behavior.
# In the following code, Gear meets this new requirement by adding an 
# observer. When a player shifts gears the set_cog or set_chainring 
# methods execute. These methods save the new value and then invoke 
# Gear’s changed method (line 20). This method then sends changed to 
# observer, passing along the current chainring and cog.

############## Page 216 ##############
class Gear
  attr_reader :chainring, :cog, :wheel, :observer

  def initialize(args)
    # ...
    @observer  = args[:observer]
  end

  # ...

  def set_cog(new_cog)
    @cog = new_cog
    changed
  end

  def set_chainring(new_chainring)
    @chainring = new_chainring
    changed
  end

  def changed
    observer.changed(chainring, cog)
  end
# ...
end

############## Page ?? ##############
# Full listing for above
class Gear
  attr_reader :chainring, :cog, :wheel, :observer
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
    @observer  = args[:observer]
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def ratio
    chainring / cog.to_f
  end

  def set_cog(new_cog)
    @cog = new_cog
    changed
  end

  def set_chainring(new_chainring)
    @chainring = new_chainring
    changed
  end

  def changed
    observer.changed(chainring, cog)
  end

end

# Gear has a new responsibility; it must notify observer when cogs or 
# chainrings change. This new responsibility is just as important as 
# its previous obligation to calculate gear inches. When a player 
# changes gears the application will be correct only if Gear sends 
# changed to observer. Your tests should prove this message gets sent.

# Not only should they prove it, but they also should do so without 
# making assertions about the result that observer’s changed method 
# returns. Just as Wheel’s tests claimed sole responsibility for 
# making assertions about the results of its own diameter method, 
# observer’s tests are responsible for making assertions about the 
# results of its changed method. The responsibility for testing a 
# message’s return value lies with its receiver. Doing so anywhere 
# else duplicates tests and raises costs.

# To avoid duplication you need a way to prove that Gear sends 
# changed to observer that does not force you to rely on checking 
# what comes back when it does. Fortunately, this is easy; you need a 
# mock. Mocks are tests of behavior, as opposed to tests of state. 
# Instead of making assertions about what a message returns, mocks 
# define an expectation that a message will get sent.

# The test below proves that Gear fulfills its responsibilities and 
# it does so without binding itself to details about how observer 
# behaves. The test creates a mock (line 4) that it injects in place 
# of the observer (line 8). Each test method tells the mock to expect 
# to receive the changed message (lines 12 and 17) and then verifies 
# that it did so (lines 14 and 20).

############## Page 217 ##############
class GearTest < MiniTest::Unit::TestCase

  def setup
    @observer = MiniTest::Mock.new
    @gear     = Gear.new(
                  chainring: 52,
                  cog:       11,
                  observer:  @observer)
  end

  def test_notifies_observers_when_cogs_change
    @observer.expect(:changed, true, [52, 27])
    @gear.set_cog(27)
    @observer.verify
  end

  def test_notifies_observers_when_chainrings_change
    @observer.expect(:changed, true, [42, 11])
    @gear.set_chainring(42)
    @observer.verify
  end
end

# This is the classic usage pattern for a mock. In the 
# notifies_observers_when_ cogs_change test above, line 12 tells the 
# mock what message to expect, line 13 triggers the behavior that 
# should cause this expectation to be met, and then line 14 asks the 
# mock to verify that it indeed was. The test passes only if sending 
# set_chainring to gear does something that causes observer to 
# receive changed with the given arguments.

# Notice that all the mock did with the message was remember that it 
# received it. If the object under test depends on the result it gets 
# back when observer receives changed, the mock can be configured to 
# return an appropriate value. This return value, however, is beside 
# the point. Mocks are meant to prove messages get sent, they return 
# results only when necessary to get tests to run.
# The fact that Gear works just fine even after you mock observer’s 
# changed method such that it does absolutely nothing proves that 
# Gear doesn’t care what that method actually does. Gear’s only 
# responsibility is to send the message; this test should restrict 
# itself to proving Gear does so.

# In a well-designed application, testing outgoing messages is 
# simple. If you have proactively injected dependencies, you can 
# easily substitute mocks. Setting expectations on these mocks allows 
# you to prove that the object under test fulfills its 
# responsibilities without duplicating assertions that belong 
# elsewhere.