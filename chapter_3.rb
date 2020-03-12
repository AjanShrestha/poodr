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
  attr_reader :chainring, :cog, :wheel
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
puts Gear.new(52, 11,  Wheel.new(26, 1.5)).gear_inches

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

############## Page 47 ##############
class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring]
    @cog       = args[:cog]
    @wheel     = args[:wheel]
  end
  # ...
end

Gear.new(
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


#### Explicitly Define Defaults ####

# Simple non-boolean defaults can be specified using Ruby’s || method
############## Page 48 ##############
# specifying defaults using ||
def initialize(args)
  @chainring = args[:chainring] || 40
  @cog       = args[:cog]       || 18
  @wheel     = args[:wheel]
end
# one you should use with caution
# The || method acts as an or condition; it first evaluates the 
# left-hand expression and then, if the expression returns false or 
# nil, proceeds to evaluate and return the result of the right-hand 
# expression. 

# The fetch method expects the key you’re fetching to be in the hash 
# and supplies several options for explicitly handling missing keys. 
# Its advantage over || is that it does not automatically return nil 
# when it fails to find your key.
############## Page 49 ##############
# specifying defaults using fetch
def initialize(args)
  @chainring = args.fetch(:chainring, 40)
  @cog       = args.fetch(:cog, 18)
  @wheel     = args[:wheel]
end
# Setting the defaults in this way means that callers can actually 
# cause @chainring to get set to false or nil, something that is not 
# possible when using the || technique.

# You can also completely remove the defaults from initialize and 
# isolate them inside of a separate wrapping method. The defaults 
# method below defines a second hash that is merged into the options 
# hash during initialization. In this case, merge has the same effect 
# as fetch; the defaults will get merged only if their keys are not 
# in the hash.
############## Page 49 ##############
# specifying defaults by merging as defaults hash
def initialize(args)
  args = defaults.merge(args)
  @chainring = args[:chainring]
  # ...
end

def defaults
  {:chainring => 40, :cog => 18}
end

# This isolation technique is perfectly reasonable for the case above 
# but it’s especially useful when the defaults are more complicated. 
# If your defaults are more than simple numbers or strings, implement 
# a defaults method.

#### Isolate Multiparameter Initialization ####
# Sometimes you will be forced to depend on a method that requires 
# fixed-order arguments where you do not own and thus cannot change 
# the method itself.

# Imagine that Gear is part of a framework and that its 
# initialization method requires fixed-order arguments. Imagine also 
# that your code has many places where you must create a new instance 
# of Gear. Gear’s initialize method is external to your application; 
# it is part of an external interface over which you have no control.

# As dire as this situation appears, you are not doomed to accept the 
# dependencies. Just as you would DRY out repetitive code inside of a 
# class, DRY out the creation of new Gear instances by creating a 
# single method to wrap the external interface. The classes in your 
# application should depend on code that you own; use a wrapping 
# method to isolate external dependencies.

# In this example, the SomeFramework::Gear class is not owned by your 
# application; it is part of an external framework. Its 
# initialization method requires fixed-order arguments. The 
# GearWrapper module was created to avoid having multiple 
# dependencies on the order of those arguments. GearWrapper isolates 
# all knowledge of the external interface in one place and, equally 
# importantly, it provides an improved interface for your application.

############## Page 50 ##############
module SomeFramework
  class Gear
    attr_reader :chainring, :cog, :wheel
    def initialize(chainring, cog, wheel)
      @chainring = chainring
      @cog       = cog
      @wheel     = wheel
    end

    def gear_inches
      puts "Called"
    end
  # ...
  end
end

# wrap the interface to protect yourself from changes
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(
      args[:chainring],
      args[:cog],
      args[:wheel]
    )
  end
end

# Now you can create a new Gear using an arguments hash.
GearWrapper.gear(
  :chainring => 52,
  :cog       => 11,
  :wheel     => Wheel.new(26, 1.5)
).gear_inches

# There are two things to note about GearWrapper. 
# First, it is a Ruby module instead of a class. 
# GearWrapper is responsible for creating new instances of 
# SomeFramework::Gear. Using a module here lets you define a separate 
# and distinct object to which you can send the gear message while 
# simultaneously conveying the idea that you don’t expect to have 
# instances of GearWrapper. You may already have experience with 
# including modules into classes; in the example above GearWrapper is 
# not meant to be included in another class, it’s meant to directly 
# respond to the gear message.

# The other interesting thing about GearWrapper is that its sole 
# purpose is to create instances of some other class. Object-oriented 
# designers have a word for objects like this; they call them 
# factories. In some circles the term factory has acquired a negative 
# connotation, but the term as used here is devoid of baggage. An 
# object whose purpose is to create other objects is a factory; the 
# word factory implies nothing more, and use of it is the most 
# expedient way to communicate this idea.

# The above technique for substituting an options hash for a list of 
# fixed-order arguments is perfect for cases where you are forced to 
# depend on external interfaces that you cannot change. Do not allow 
# these kinds of external dependencies to permeate your code; protect 
# yourself by wrapping each in a method that is owned by your own 
# application.


### Managing Dependency Direction ###
# Dependencies always have a direction

#### Reversing Dependencies ####

############## Page 52 ##############
class Gear
  attr_reader :chainring, :cog
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def gear_inches(diameter)
    ratio * diameter
  end

  def ratio
    chainring / cog.to_f
  end
# ...
end

class Wheel
  attr_reader :rim, :tire, :gear
  def initialize(rim, tire, chainring, cog)
    @rim  = rim
    @tire = tire
    @gear = Gear.new(chainring, cog)
  end

  def diameter
    rim + (tire * 2)
  end

  def gear_inches
    gear.gear_inches(diameter)
  end
# ...
end

puts Wheel.new(26, 1.5, 52, 11).gear_inches

# This reversal of dependencies does no apparent harm. Calculating 
# gear_inches still requires collaboration between Gear and Wheel and 
# the result of the calculation is unaffected by the reversal. One 
# could infer that the direction of the dependency does not matter, 
# that it makes no difference whether Gear depends on Wheel or vice 
# versa.
# Indeed, in an application that never changed, your choice would not 
# matter. However, your application will change and it’s in that 
# dynamic future where this present decision has repercussions. The 
# choices you make about the direction of dependencies have far 
# reaching consequences that manifest themselves for the life of your 
# application. If you get this right, your application will be 
# pleasant to work on and easy to maintain. If you get it wrong then 
# the dependencies will gradually take over and the application will 
# become harder and harder to change.


### Choosing Dependency Direction ###
# depend on things that change less often than you do.
# This short statement belies the sophistication of the idea, which 
# is based on three simple truths about code:
#   Some classes are more likely than others to have changes in 
#     requirements.
#   Concrete classes are more likely to change than abstract classes.
#   Changing a class that has many dependents will result in 
#     widespread consequences.


#### Understanding Likelihood of Change ####
# The idea that some classes are more likely to change than others 
# applies not only to the code that you write for your own 
# application but also to the code that you use but did not write. 
# The Ruby base classes and the other framework code that you rely on 
# both have their own inherent likelihood of change.

# You are fortunate in that Ruby base classes change a great deal 
# less often than your own code. Ruby base classes always change less 
# often than your own classes and you can continue to depend on them 
# without another thought.

# Framework classes are another story; only you can assess how mature 
# your frameworks are. In general, any framework you use will be more 
# stable than the code you write, but it’s certainly possible to 
# choose a framework that is undergoing such rapid development that 
# its code changes more often than yours.

# Regardless of its origin, every class used in your application can 
# be ranked along a scale of how likely it is to undergo a change 
# relative to all other classes. This ranking is one key piece of 
# information to consider when choosing the direction of dependencies.


#### Recognizing Concretions and Abstractions ####
# The term abstract is used here just as Merriam-Webster defines it, 
# as “disassociated from any specific instance,” and, as so many 
# things in Ruby, represents an idea about code as opposed to a 
# specific technical restriction.

# It is impossible to create an abstraction unknowingly or by 
# accident; in statically typed languages defining an interface is 
# always intentional.

# In Ruby, when you inject Wheel into Gear such that Gear then 
# depends on a Duck who responds to diameter, you are, however 
# casually, defining an interface. This inter- face is an abstraction 
# of the idea that a certain category of things will have a diameter. 
# The abstraction was harvested from a concrete class; the idea is 
# now “disassociated from any specific instance.”

# The wonderful thing about abstractions is that they represent 
# common, stable qualities. They are less likely to change than are 
# the concrete classes from which they were extracted. Depending on 
# an abstraction is always safer than depending on a concretion 
# because by its very nature, the abstraction is more stable. 

#### Avoiding Dependent-Laden Classes ####
# The consequences of changing a dependent- laden class are quite 
# obvious—not so apparent are the consequences of even having a 
# dependent-laden class. A class that, if changed, will cause changes 
# to ripple through the application, will be under enormous pressure 
# to never change. Ever. Under any circumstances whatsoever. Your 
# application may be permanently handicapped by your reluctance to 
# pay the price required to make a change to this class.