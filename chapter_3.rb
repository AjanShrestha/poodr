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