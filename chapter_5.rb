# Reducing Costs with Duck Typing

# The purpose of object-oriented design is to reduce the cost of 
# change. Now that you know messages are at the design center of your 
# application, and now that you are committed to the construction of 
# rigorously defined public interfaces, you can combine these two 
# ideas into a powerful design technique that further reduces your 
# costs.
# This technique is known as duck typing. Duck types are public 
# interfaces that are not tied to any specific class. These 
# across-class interfaces add enormous flexibility to your 
# application by replacing costly dependencies on class with more 
# forgiving dependencies on messages.
# Duck typed objects are chameleons that are defined more by their 
# behavior than by their class. This is how the technique gets its 
# name; if an object quacks like a duck and walks like a duck, then 
# its class is immaterial, it’s a duck.

## Understanding Duck Typing ##

# Just as beauty is in the physical world, within your application an 
# object’s type is in the eye of the beholder. Users of an object 
# need not, and should not, be concerned about its class. Class is 
# just one way for an object to acquire a public interface; the 
# public interface an object obtains by way of its class may be one 
# of several that it contains. Applications may define many public 
# interfaces that are not related to one specific class; these 
# interfaces cut across class. Users of any object can blithely 
# expect it to act like any, or all, of the public interfaces it 
# implements. It’s not what an object is that matters, it’s what it 
# does.
# If every object trusts all others to be what it expects at any 
# given moment, and any object can be any kind of thing, the design 
# possibilities are infinite. These possibilities can be used to 
# create flexible designs that are marvels of structured creativity 
# or, alternatively, to construct terrifying designs that are 
# incomprehensibly chaotic.
# Using this flexibility wisely requires that you recognize these 
# across-class types and construct their public interfaces as 
# intentionally and as diligently as you did those of within-class 
# types back in Chapter 4, Creating Flexible Interfaces. Across-class 
# types, duck types, have public interfaces that represent a contract 
# that must be explicit and well-documented.

### Overlooking the Duck ###

############## Page 87 ##############
class Trip
  attr_reader :bicycles, :customers, :vehicle

  # this 'mechanic' argument could be of any class
  def prepare(mechanic)
    mechani.prepare_bicycles(bicycles)
  end

  # ...
end

# if you happend to pass an instance of *this* class.
# it works
class Mechanic
  def prepare_bicycles(bicycles)
    bicycles.each{|bicycle| prepare_bicycle(bicycle)}
  end

  def prepare_bicycle(bicycle)
    # ...
  end
end

# Trip’s prepare method sends message prepare_bicycles to the object 
# contained in its mechanic parameter. Notice that the Mechanic class 
# is not referenced; even though the parameter name is mechanic, the 
# object it contains could be of any class.

# Figure 5.1 contains the corresponding sequence diagram, where an 
# outside object gets everything started by sending prepare to Trip, 
# passing along an argument.
# The prepare method has no explicit dependency on the Mechanic class 
# but it does depend on receiving an object that can respond to 
# prepare_bicycles. This dependency is so fundamental that it’s easy 
# to miss or to discount, but nonetheless, it exists. Trip’s prepare 
# method firmly believes that its argument contains a preparer of 
# bicycles.


### Compunding the Problem ###
# Imagine that requirements change. In addition to a mechanic, trip 
# preparation now involves a trip coordinator and a driver. Following 
# the established pattern of the code, you create new TripCoordinator 
# and Driver classes and give them the behavior for which they are 
# responsible. You also change Trip’s prepare method to invoke the 
# correct behavior from each of its arguments.


# The new TripCoordinator and Driver classes are simple and 
# inoffensive but Trip’s prepare method is now a cause for alarm. It 
# refers to three different classes by name and knows specific 
# methods implemented in each. Risks have dramatically gone up. 
# Trip’s prepare method might be forced to change because of a change 
# elsewhere and it might unexpectedly break as the result of a 
# distant, unrelated change.

############## Page 88 ##############
# Trip preparation becomes more complicated
class Trip
  attr_reader :bicycles, :customers,:vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.gas_up(vehicle)
        preparer.fill_water_tank(vehicle)
      end
    }
  end
end

# when you introduce TripCoordinator and Driver
class TripCoordinator
  def buy_food(customers)
    # ...
  end
end

class Driver
  def gas_up(vehicle)
    # ...
  end

  def fill_water_tank(vehicle)
    # ...
  end
end

# This code is the first step in a process that will paint you into a 
# corner with no way out. Code like this gets written when 
# programmers are blinded by existing classes and neglect to notice 
# that they have overlooked important messages; this dependent-laden 
# code is a natural outgrowth of a class-based perspective.

# If your design imagination is constrained by class and you find 
# yourself unex- pectedly dealing with objects that don’t understand 
# the message you are sending, your tendency is to go hunt for 
# messages that these new objects do understand. Because the new 
# arguments are instances of TripCoordinator and Driver, you 
# naturally examine the public interfaces of those classes and find 
# buy_food, gas_up and fill_water_tank. This is the behavior that 
# prepare wants.

# The most obvious way to invoke this behavior is to send these very 
# messages, but now you’re stuck. Every one of your arguments is of a 
# different class and implements different methods; you must 
# determine each argument’s class to know which message to send. 
# Adding a case statement that switches on class solves the problem 
# of sending the correct message to the correct object but causes an 
# explosion of dependencies.

# Count the number of new dependencies in the prepare method. It 
# relies on specific classes, no others will do. It relies on the 
# explicit names of those classes. It knows the names of the messages 
# that each class understands, along with the arguments that those 
# messages require. All of this knowledge increases risk; many 
# distant changes will now have side effects on this code.

# To make matters worse, this style of code propagates itself. When 
# another new trip preparer appears, you, or the next person down the 
# programming line, will add a new when branch to the case statement. 
# Your application will accrue more and more methods like this, where 
# the method knows many class names and sends a specific message 
# based on class. The logical endpoint of this programming style is a 
# stiff and inflexible application, where it eventually becomes 
# easier to rewrite everything than to change anything.

# Figure 5.2 shows the new sequence diagram. Every sequence diagram 
# thus far has been simpler than its corresponding code, but this new 
# diagram looks frighten- ingly complicated. This complexity is a 
# warning. Sequence diagrams should always be simpler than the code 
# they represent; when they are not, something is wrong with the 
# design.


### Finding the Duck ###
# The key to removing the dependencies is to recognize that because 
# Trip’s prepare method serves a single purpose, its arguments arrive 
# wishing to collaborate to accom- plish a single goal. Every 
# argument is here for the same reason and that reason is unre- lated 
# to the argument’s underlying class.

# **
# Avoid getting sidetracked by your knowledge of what each argument’s 
# class already does; think instead about what prepare needs. 
# Considered from prepare’s point of view, the problem is 
# straightforward. The prepare method wants to prepare the trip. Its 
# arguments arrive ready to collaborate in trip preparation. The 
# design would be simpler if prepare just trusted them to do so.

# Figure 5.3 illustrates this idea. Here the prepare method doesn’t 
# have a preordained expectation about the class of its arguments, 
# instead it expects each to be a “Preparer.”

# This expectation neatly turns the tables. You’ve pried yourself 
# loose from existing classes and invented a duck type. The next step 
# is to ask what message the prepare method can fruitfully send each 
# Preparer. From this point of view, the answer is obvious: 
# prepare_trip.

# Figure 5.4 introduces the new message. Trip’s prepare method now 
# expects its arguments to be Preparers that can respond to 
# prepare_trip.

# **
# What kind of thing is Preparer? At this point it has no concrete 
# existence; it’s an abstraction, an agreement about the public 
# interface on an idea. It’s a figment of design.

# ***
# Objects that implement prepare_trip are Preparers and, conversely, 
# objects that interact with Preparers only need trust them to 
# implement the Preparer interface. Once you see this underlying 
# abstraction, it’s easy to fix the code. Mechanic, TripCoordinator 
# and Driver should behave like Preparers; they should implement 
# prepare_trip.

############## Page 93 ##############
# Trip preparation becomes easier
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      preparer.prepare_trip(self)
    }
  end
end

# when every prepare is a Duck
# that responds to 'prepare_trip'
class Mechanic
  def prepare_trip(trip)
    trip.bicycles.each {|bicycle|
      prepare_bicycle(bicycle)
    }
  end

  # ...
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end

  # ...
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up(vehicle)
    fill_water_tank(vehicle)
  end

  # ...
end

# The prepare method can now accept new Preparers without being 
# forced to change, and it’s easy to create additional Preparers if 
# the need arises.


### Consequences of Duck Typing ###
# This new implementation has a pleasing symmetry that suggests a 
# rightness about the design, but the consequences of introducing a 
# duck type go deeper.

# In the initial example, the prepare method depends on a concrete 
# class. In this most recent example, prepare depends on a duck type. 
# The path between these examples leads through a thicket of 
# complicated, dependent-laden code.

# The concreteness of the first example makes it simple to understand 
# but danger- ous to extend. The final, duck typed, alternative is 
# more abstract; it places slightly greater demands on your 
# understanding but in return offers ease of extension. Now that you 
# have discovered the duck, you can elicit new behavior from your 
# application without changing any existing code; you simply turn 
# another object into a Preparer and pass it into Trip’s prepare 
# method.

# **
# This tension between the costs of concretion and the costs of 
# abstraction is fundamental to object-oriented design. Concrete code 
# is easy to understand but costly to extend. Abstract code may 
# initially seem more obscure but, once understood, is far easier to 
# change. Use of a duck type moves your code along the scale from 
# more concrete to more abstract, making the code easier to extend 
# but casting a veil over the underlying class of the duck.

# ***
# The ability to tolerate ambiguity about the class of an object is 
# the hallmark of a confident designer. Once you begin to treat your 
# objects as if they are defined by their behavior rather than by 
# their class, you enter into a new realm of expressive flexible 
# design.


# Polymorphism

# The term polymorphism is commonly used in object-oriented 
# programming but its use in everyday speech is rare enough to 
# warrant a definition.
# First, a general definition: Morph is the Greek word for form, 
# morphism is the state of having a form, and polymorphism is the 
# state of having many forms. Biologists use this word. Darwin’s 
# famous finches are polymorphic; a single species has many forms.
# Polymorphism in OOP refers to the ability of many different objects 
# to respond to the same message. Senders of the message need not 
# care about the class of the receiver; receivers supply their own 
# specific version of the behavior.
# A single message thus has many (poly) forms (morphs).
# There are a number of ways to achieve polymorphism; duck typing, as 
# you have surely guessed, is one. Inheritance and behavior sharing 
# (via Ruby modules) are others, but those are topics for the next 
# chapters.
# Polymorphic methods honor an implicit bargain; they agree to be 
# interchangeable from the sender’s point of view. Any object 
# implementing a polymorphic method can be substituted for any other; 
# the sender of the message need not know or care about this 
# substitution.
# This substitutability doesn’t happen by magic. When you use 
# polymorphism it’s up to you to make sure all of your objects are 
# well-behaved.


## Writing Code That Relies on Ducks ##
# Using duck typing relies on your ability to recognize the places 
# where your application would benefit from across-class interfaces. 
# It is relatively easy to implement a duck type; your design 
# challenge is to notice that you need one and to abstract its 
# interface.

### Recognizing Hidden Ducks ### 
# Many times unacknowledged duck types already exist, lurking within 
# existing code. Several common coding patterns indicate the presence 
# of a hidden duck. You can replace the following with ducks:
# • Case statements that switch on class 
# • kind_of? and is_a?
# • responds_to?

#### Case Statements That Switch on Class ####
############## Page 96 ##############
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.gas_up(vehicle)
        preparer.fill_water_tank(vehicle)
      end
    }
  end
end

# When you see this pattern you know that all of the preparers must 
# share something in common; they arrive here because of that common 
# thing. Examine the code and ask yourself, “What is it that prepare 
# wants from each of its arguments?”
# The answer to that question suggests the message you should send; 
# this message begins to define the underlying duck type.
# Here the prepare method wants its arguments to prepare the trip. 
# Thus,prepare_trip becomes a method in the public interface of the 
# new Preparer duck.

#### kind_of? and is_a? ####
# The kind_of? and is_a? messages (they are synonymous) also check 
# class.

############## Page 97 ##############
if preparer.kind_of?(Mechanic)
  preparer.prepare_bicycles(bicycle)
elsif preparer.kind_of?(TripCoordinator)
  preparer.buy_food(customers)
elsif preparer.kind_of?(Driver)
  preparer.gas_up(vehicle)
  preparer.fill_water_tank(vehicle)
end

# Using kind_of? is no different than using a case statement that 
# switches on class; they are the same thing, they cause exactly the 
# same problems, and they should be corrected using the same 
# techniques.

#### responds_to? ####
# Programmers who understand that they should not depend on class 
# names but who haven’t yet made the leap to duck types are tempted 
# to replace kind_of? with responds_to?.

############## Page 97 ##############
if preparer.responds_to?(:prepare_bicycles)
  preparer.prepare_bicycles(bicycle)
elsif preparer.responds_to?(:buy_food)
  preparer.buy_food(customers)
elsif preparer.responds_to?(:gas_up)
  preparer.gas_up(vehicle)
  preparer.fill_water_tank(vehicle)
end

# While this slightly decreases the number of dependencies, this code 
# still has too many. The class names are gone but the code is still 
# very bound to class. What object will know prepare_bicycles other 
# than Mechanic? Don’t be fooled by the removal of explicit class 
# references. This example still expects very specific classes.

# Even if you are in a situation where more than one class implements 
# prepare_bicycles or buy_food, this code pattern still contains 
# unnecessary dependencies; it controls rather than trusts other 
# objects.

### Placing Trust in Your Ducks ###
# Use of kind_of?, is_a?, responds_to?, and case statements that 
# switch on your classes indicate the presence of an unidentified 
# duck. In each case the code is effectively saying “I know who you 
# are and because of that I know what you do.” This knowledge exposes 
# a lack of trust in collaborating objects and acts as a millstone 
# around your object’s neck. It introduces dependencies that make 
# code difficult to change.

# Just as in Demeter violations, this style of code is an indication 
# that you are missing an object, one whose public interface you have 
# not yet discovered. 
# **
# The fact that the missing object is a duck type instead of a 
# concrete class matters not at all; it’s the interface that matters, 
# not the class of the object that implements it.

# Flexible applications are built on objects that operate on trust; 
# it is your job to make your objects trustworthy. When you see these 
# code patterns, concentrate on the offending code’s expectations and 
# use those expectations to find the duck type. Once you have a duck 
# type in mind, define its interface, implement that interface where 
# necessary, and then trust those implementers to behave correctly.

### Documenting Duck Types ###
# The simplest kind of duck type is one that exists merely as an 
# agreement about its public interface. This chapter’s example code 
# implements that kind of duck, where several different classes 
# implement prepare_trip and can thus be treated like Preparers.

# The Preparer duck type and its public interface are a concrete part 
# of the design but a virtual part of the code. Preparers are 
# abstract; this gives them strength as a design tool but this very 
# abstraction makes the duck type less than obvious in the code.

# When you create duck types you must both document and test their 
# public interfaces. Fortunately, good tests are the best 
# documentation, so you are already halfway done; you need only write 
# the tests.

### Sharing Code Between Ducks ###

# In this chapter, Preparer ducks provide class-specific versions of 
# the behavior required by their interface. Mechanic, Driver and 
# TripCoordinator each implement method prepare_trip. This method 
# signature is the only thing they have in common. They share only 
# the interface, not the implementation.

# Once you start using duck types, however, you’ll find that classes 
# that implement them often need to share some behavior in common. 

### Choose Your Ducks Wisely ###

# If sending a message based on the class of the receiving object is 
# the death knell for your application, why is this code acceptable?

############## Page 99 ##############
# A convenience wrapper for <tt>find(:first, *args)</tt>.
# You can pass in all the same arguments to this
# method as you can to <tt>find(:first)</tt>.
def first(*args)
  if args.any?
    if args.first.kind_of?(Integer) ||
        (loaded? && !args.first.kind_of?(Hash))
      to_a.first(*args)
    else
      apply_finder_options(args.first).first
    end
  else
    find_first
  end
end
# !x

# The major difference between this example and the previous ones is 
# the stability of the classes that are being checked. When first 
# depends on Integer and Hash, it is depending on core Ruby classes 
# that are far more stable than it is. The likelihood of Integer or 
# Hash changing in such a way as to force first to change is 
# vanishingly small. This dependency is safe. There probably is a 
# duck type hidden somewhere in this code but it will likely not 
# reduce your overall application costs to find and implement it.

# From this example you can see that the decision to create a new 
# duck type relies on judgment. The purpose of design is to lower 
# costs; bring this measuring stick to every situation. If creating a 
# duck type would reduce unstable dependencies, do so. Use your best 
# judgment.
  
# The above example’s underlying duck spans Integer and Hash and 
# therefore its implementation would require making changes to Ruby 
# base classes. Changing base classes is known as monkey patching and 
# is a delightful feature of Ruby but can be perilous in untutored 
# hands.
  
# Implementing duck types across your own classes is one thing, 
# changing Ruby base classes to introduce new duck types is quite 
# another. The tradeoffs are different; the risks are greater. 
# Neither of these considerations should prevent you from monkey 
# patching Ruby at need; however, you must be able to eloquently 
# defend this design decision. The standard of proof is high.


## Conquering a Fear of Duck Typing

### Subverting Duck Types with Static Typing ###
# Relying on dynamic typing makes some people uncomfortable. For 
# some, this discomfort is caused by a lack of experience, for 
# others, by a belief that static typing is more reliable.

# The lack-of-experience problem cures itself, but the belief that 
# static typing is fundamentally preferable often persists because it 
# is self-reinforcing. Programmers who fear dynamic typing tend to 
# check the classes of objects in their code; these very checks 
# subvert the power of dynamic typing, making it impossible to use 
# duck types.

# Methods that cannot behave correctly unless they know the classes 
# of their arguments will fail (with type errors) when new classes 
# appear. Programmers who believe in static typing take these 
# failures as proof that more type checking is needed. When more 
# checks are added, the code becomes less flexible and even more 
# dependent on class. The new dependencies cause additional type 
# failures, and the programmer responds to these failures by adding 
# yet more type checking. Anyone caught in this loop will naturally 
# have a hard time believing that the solution to their type problem 
# is to remove type checking altogether.

# Duck typing provides a way out of this trap. It removes the 
# dependencies on class and thus avoids the subsequent type failures. 
# It reveals stable abstractions on which your code can safely depend.

### Static versus Dynamic Typing ###
# This section compares dynamic and static typing, hoping to allay 
# any fears that keep you from being fully committed to dynamic types.

# Static and dynamic typing both make promises and each has costs and 
# benefits. Static typing aficionados cite the following qualities:
# • The compiler unearths type errors at compile time.
# • Visible type information serves as documentation.
# • Compiled code is optimized to run quickly.

# These qualities represent strengths in a programming language only 
# if you accept this set of corresponding assumptions:
# • Runtime type errors will occur unless the compiler performs type 
# checks.
# • Programmers will not otherwise understand the code; they cannot 
# infer an object’s type from its context.
# • The application will run too slowly without these optimizations.

# Dynamic typing proponents list these qualities:
# • Code is interpreted and can be dynamically loaded; there is no 
# compile/make cycle. 
# • Source code does not include explicit type information.
# • Metaprogramming is easier.

# These qualities are strengths if you accept this set of assumptions:
# • Overall application development is faster without a compile/make 
# cycle.
# • Programmers find the code easier to understand when it does not 
# contain type declarations; they can infer an object’s type from its 
# context.
# • Metaprogramming is a desirable language feature.