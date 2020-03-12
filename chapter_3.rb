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