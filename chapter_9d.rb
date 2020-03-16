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
