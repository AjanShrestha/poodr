# Managing Dependencies
# For any desired behavior, an object either 
#   knows it personally, 
#   inherits it, or 
#   knows another object who knows it.
# To collaborate, an object must know something know about others. 
# Knowing creates a dependency. If not managed carefully, these 
# dependencies will strangle your application.

# Understanding Dependencies
# An object depends on another object if, when one object changes, 
# the other might be forced to change in turn.
############## Page 36 ##############
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end

  def ratio
    chainring / cog.to_f
  end
# ...
end

class Wheel
  attr_reader :rim, :tire
  def initialize(rim, tire)
    @rim = rim
    @tire = tire
  end

  def diameter
    rim + (tire * 2)
  end
# ...
end

puts Gear.new(52, 11, 26, 1.5).gear_inches

# Recognizing Dependencies
# An object has a dependency when it knows
#   The name of another class. Gear expects a class named Wheel to 
#     exist.
#   The name of a message that it intends to send to someone other
#     than self. Gear expects a Wheel instance to respond to diameter.
#   The arguments that a message requires. Gear knows that Wheel.new
#     requires a rim and a tire.
#   The order of those arguments. Gear knows the first argument to
#     Wheel.new should be rim, the second, tire.


# Coupling Between Objects(CBO)
# These dependencies couple Gear to Wheel.
# Alternatively, coupling creates a dependency.
# The more tighly coupled two objects are, the more they behave
#   like a single entity.
# If you make a change to Wheel, you may need to make changes in Gear.
# If you want to reuse Gear, Wheel comes along.
# When you test Gear, you'll be testing Wheel too.
# When two (or three or more) objects are so tightly coupled that 
#   they behave as a unit, it’s impossible to reuse just one. Changes 
#   to one object force changes to all. Left unchecked, unmanaged 
#   dependencies cause an entire application to become an 
#   entangled mess. A day will come when it’s easier to rewrite 
#   everything than to change anything.

# Other dependencies
# Message chaining
#   Creates a dependency between the original object and every object
#   and message along the way to its ultimate target.
#   Any change in intermediate objects forces change in first object.
# Test Driven Development
#   Tightly coupled testing code.
#   Always refacoring required despite no behavior changes to code.
#   Tests begins to seem costly relative to their value.


## Writing Loosely Couple Code ##
### Inject Dependencies ###
# Referring to another class by its name creates a major sticky spot.

############## Page 39 ##############
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end

# ...
end

puts Gear.new(52, 11, 26, 1.5).gear_inches

# The immediate, obvious consequene of this reference is that if
# the name of the Wheel class changes, Gear's gear_inches method
# must also change.

# Deeper Problem
# When Gear hard-codes a reference to Wheel deep inside its
# gear_inches method, it is explicitly declaring that it is only
# willing to calculate gear inches for instances of Wheel.
# Gear refuses to collaborate with any other kind of object, even
# if that object has a diameter and use gears.

# The code above exposes an unjustified attachment to static types.
# It is not the class of the object that's important, it's the
# message you plan to send to it.
# Gear needs access to an object that can responde to diameter; a
# duck type. Gear doesn't care about the class of that object and
# it's initialization. It just needs an object that knows diameter.

# Gear becomes less useful when it knows too much about other objects
# if it knew less it could do more.

############## Page 41 ##############
class Gear
  attr_reader :chainring, :cog, :Wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog = cog
    @wheel = wheel
  end

  def gear_inches
    ratio * wheel.diameter
  end
# ...
end

# Gear expects a 'Duck' that knows 'diameter'
puts Gear.new(52, 11, 26, 1.5).gear_inches

# Gear now uses the @wheel variable to hold, and the wheel method to 
# access, this object, but don’t be fooled, Gear doesn’t know or care 
# that the object might be an instance of class Wheel. Gear only 
# knows that it holds an object that responds to diameter.

# This change is so small it is almost invisible, but coding in this 
# style has huge benefits. Moving the creation of the new Wheel 
# instance outside of Gear decouples the two classes. Gear can now 
# collaborate with any object that implements diameter.

# This technique is known as dependency injection. Despite its 
# fearsome reputation, dependency injection truly is this simple. 
# Gear previously had explicit dependencies on the Wheel class and on 
# the type and order of its initialization arguments, but through 
# injection these dependencies have been reduced to a single 
# dependency on the diameter method. Gear is now smarter because it 
# knows less.

### Isolate Dependencies ###
# If prevented from achieving perfection, your goals should switch to 
# improving the overall situation by leaving the code better than you 
# found it.
# if you cannot remove unnecessary dependencies, you should isolate 
# them within your class
# you should isolate unnecessary dependences so that they are easy to 
# spot and reduce when circumstances permit.

#### Isolate Instance Creation ####
# If you are so constrained that you cannot change the code to inject 
# a Wheel into a Gear, you should isolate the creation of a new Wheel 
# inside the Gear class. The intent is to explicitly expose the 
# dependency while reducing its reach into your class.

############## Page 43 ##############
class Gear
  attr_reader :chainring, :cog, :rim, :tire, :wheel
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @wheel     = Wheel.new(rim, tire)
  end

  def gear_inches
    ratio * wheel.diameter
  end
end
# ...

# Notice that this technique unconditionally creates a new Wheel each 
# time a new Gear is created.

############## Page 43 ##############
class Gear
  attr_reader :chainring, :cog, :rim, :tire, :wheel
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @rim       = rim
    @tire      = tire
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def wheel
    @wheel ||= Wheel.new(rim, tire)
  end
end
# ...

# This new method lazily creates a new instance of Wheel, using 
# Ruby’s ||= operator. In this case, creation of a new instance of 
# Wheel is deferred until gear_inches invokes the new wheel method.

# In both of these examples Gear still knows far too much; it still 
# takes rim and tire as initialization arguments and it still creates 
# its own new instance of Wheel. Gear is still stuck to Wheel; it can 
# calculate the gear inches of no other kind of object.
# However, an improvement has been made. These coding styles reduce 
# the number of dependencies in gear_inches while publicly exposing 
# Gear’s dependency on Wheel. They reveal dependencies instead of 
# concealing them, lowering the barriers to reuse and making the code 
# easier to refactor when circumstances allow. This change makes the 
# code more agile; it can more easily adapt to the unknown future.

# An application whose classes are sprinkled with entangled and 
# obscure class name references is unwieldy and inflexible, while one 
# whose class name dependencies are concise, explicit, and isolated 
# can easily adapt to new requirements.


#### Isolate Vulnerable External Messages ####
# external messages, i.e., messages that are “sent to someone other 
# than self.” 
# For example, the gear_inches method below sends ratio and wheel to 
# self, but sends diameter to wheel:

############## Page 44 ##############
def gear_inches
  ratio * wheel.diameter
end

# Imageine something complex computation

############## Page 44 ##############
def gear_inches
  #... a few lines of scary math
  foo = some_intermediate_result * wheel.diameter
  #... more lines of scary math
end

# Now wheel.diameter is embedded deeply inside a complex method. This 
# complex method depends on Gear responding to wheel and on wheel 
# responding to diameter. Embedding this external dependency inside 
# the gear_inches method is unnecessary and increases its 
# vulnerability.

# You can reduce your chance of being forced to make a change to 
# gear_inches by removing the external dependency and encapsulating 
# it in a method of its own

############## Page 45 ##############
def gear_inches
  # ... a few lines of scary math
  foo = some_intermediate_result * diameter
  # ... more lines of scary math
end

def diameter
  wheel.diameter
end

# In the original code, gear_inches knew that wheel had a diameter. 
# This knowledge is a dangerous dependency that couples gear_inches 
# to an external object and one of its methods. After this change, 
# gear_inches is more abstract. Gear now isolates wheel.diameter in a 
# separate method and gear_inches can depend on a message sent to 
# self.

# This technique becomes necessary when a class contains embedded 
# references to a message that is likely to change. Isolating the 
# reference provides some insurance against being affected by that 
# change. Although not every external method is a candidate for this 
# preemptive isolation, it’s worth examining your code, looking for 
# and wrapping the most vulnerable dependencies.


### Remove Argument-Order Dependenciees ###
# When you send a message that requires arguments, you, as the 
# sender, cannot avoid having knowledge of those arguments. This 
# dependency is unavoidable. However, passing arguments often 
# involves a second, more subtle, dependency. Many method signatures 
# not only require arguments, but they also require that those 
# arguments be passed in a specific, fixed order.

############## Page 46 ##############
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end
# ...
end

Gear.new(
  52,
  11,
  Wheel.new(26, 1.5)
).gear_inches

# Senders of new depend on the order of the arguments as they are 
# specified in Gear’s initialize method. If that order changes, all 
# the senders will be forced to change.

#### Use Hashes for Initialization Arguments ####
# There’s a simple way to avoid depending on fixed-order arguments. 
# If you have control over the Gear initialize method, change the 
# code to take a hash of options instead of a fixed list of 
# parameters.

# The initialize method now takes just one argument, args, a hash 
# that contains all of the inputs. The method has been changed to 
# extract its arguments from this hash.

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end
  # ...
end

Gear.end(
  :chainring => 52,
  :cog       => 11,
  :wheel     => Wheel.new(26, 1.5)
).gear_inches

# The above technique has several advantages. 
# The first and most obvious is that it removes every dependency on 
# argument order. Gear is now free to add or remove initialization 
# arguments and defaults, secure in the knowledge that no change will 
# have side effects in other code.
# This technique adds verbosity. In many situations verbosity is a 
# detriment, but in this case it has value. The verbosity exists at 
# the intersection between the needs of the present and the 
# uncertainty of the future. Using fixed-order arguments requires 
# less code today but you pay for this decrease in volume of code 
# with an increase in the risk that changes will cascade into 
# dependents later.
# It lost its dependency on argument order but it gained a dependency 
# on the names of the keys in the argument hash. This change is 
# healthy. The new dependency is more stable than the old, and thus 
# this code faces less risk of being forced to change. Additionally, 
# and perhaps unexpectedly, the hash provides one new, secondary 
# benefit: The key names in the hash furnish explicit documentation 
# about the arguments. This is a byproduct of using a hash but the 
# fact that it is unintentional makes it no less useful. Future 
# maintainers of this code will be grateful for the information.