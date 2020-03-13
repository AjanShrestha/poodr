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

## Understanding Duck Typing

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