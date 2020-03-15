# Sharing Role Behavior with Modules #

# What will happen when FastFeet develops a need for recumbent mountain bikes?
# If the solution to this new design problem feels elusive, that’s 
# perfectly under- standable. Creation of a recumbent mountain bike 
# subclass requires combining the qualities of two existing 
# subclasses, something that inheritance cannot readily accommodate. 
# Even more distressing is the fact that this failure illustrates 
# just one of several ways in which inheritance can go wrong.

# **
# To reap benefits from using inheritance you must understand not 
# only how to write inheritable code but also when it makes sense to 
# do so. Use of classical inheritance is always optional; every 
# problem that it solves can be solved another way. Because no design 
# technique is free, creating the most cost-effective application 
# requires making informed tradeoffs between the relative costs and 
# likely benefits of alternatives.

## Understanding Roles ##

# Some problems require sharing behavior among otherwise unrelated 
# objects. This common behavior is orthogonal to class; it’s a role 
# an object plays. Many of the roles needed by an application will be 
# obvious at design time, but it’s also common to discover 
# unanticipated roles as you write the code.

# When formerly unrelated objects begin to play a common role, they 
# enter into a relationship with the objects for whom they play the 
# role. These relationships are not as visible as those created by 
# the subclass/superclass requirements of classical inheri- tance but 
# they exist nonetheless. Using a role creates dependencies among the 
# objects involved and these dependencies introduce risks that you 
# must take into account when deciding among design options.

### Finding Roles ###

# The Preparer duck type from Chapter 5, Reducing Costs with Duck 
# Typing, is a role. Objects that implement Preparer’s interface play 
# this role. Mechanic, TripCoordinator, and Driver each implement 
# prepare_trip; therefore, other objects can interact with them as if 
# they are Preparers without concern for their underlying class.

# The existence of a Preparer role suggests that there’s also a 
# parallel Preparable role (these things often come in pairs). The 
# Trip class acts as a Preparable in the Chapter 5 example; it 
# implements the Prepareable interface. This interface includes all 
# of the messages that any Preparer might expect to send to a 
# Preparable, that is, the methods bicycles, customers, and vehicle.
# The Preparable role is not terribly obvious because Trip is its 
# only player but it’s important to recognize that it exists.

# Although the Preparer role has multiple players, it is so simple 
# that it is entirely defined by its interface. To play this role all 
# an object need do is implement its own personal version of 
# prepare_trip. Objects that act as Preparers have only this 
# interface in common. They share the method signature but no other 
# code.

# Preparer and Preparable are perfectly legitimate duck types. It’s 
# far more common, however, to discover more sophisticated roles, 
# ones where the role requires not only specific message signatures, 
# but also specific behavior. When a role needs shared behavior 
# you’re faced with the problem of organizing the shared code. Ideally
# this code would be defined in a single place but be usable by any 
# object that wished to act as the duck type and play the role.

# **
# Many object-oriented languages provide a way to define a named 
# group of methods that are independent of class and can be mixed in 
# to any object. In Ruby, these mix-ins are called modules. Methods 
# can be defined in a module and then the module can be added to any 
# object. Modules thus provide a perfect way to allow objects of 
# different classes to play a common role using a single set of code.
# When an object includes a module, the methods defined therein 
# become available via automatic delegation. If this sounds like 
# classical inheritance, it also looks like it, at least from the 
# point of view of the including object. From that object’s point of 
# view, messages arrive, it doesn’t understand them, they get 
# automatically routed somewhere else, the correct method 
# implementation is magically found, it is executed, and the response 
# is returned.
# Once you start putting code into modules and adding modules to 
# objects, you expand the set of messages to which an object can 
# respond and enter a new realm of design complexity. An object that 
# directly implements few methods might still have a very large 
# response set. The total set of messages to which an object can 
# respond includes
# • Those it implements
# • Those implemented in all objects above it in the hierarchy
# • Those implemented in any module that has been added to it
# • Those implemented in all modules added to any object above it in 
#   the hierarchy

### Organizing Responsibilities ###

# Determining if an unscheduled bike, mechanic, or vehicle is 
# available to participate in a trip is not as simple as looking to 
# see if it’s idle throughout the interval during which the trip is 
# scheduled. These real-world things need a bit of downtime between 
# trips, they cannot finish a trip on one day and start another the 
# next. Bicycles and motor vehicles must undergo maintenance, and 
# mechanics need a rest from being nice to customers and a chance to 
# do their laundry.
# The requirements are that bicycles have a minimum of one day 
# between trips, vehicles a minimum of three days, and mechanics, 
# four days.


# Figure 7.1 shows an implementation where the Schedule itself takes 
# responsibility for knowing the correct lead time. The schedulable? 
# method knows all the possible values and it checks the class of its 
# incoming target argument to decide which lead time to use.

# You’ve seen the pattern of checking class to know what message to 
# send; here the Schedule checks class to know what value to use. In 
# both cases Schedule knows too much. This knowledge doesn’t belong 
# in Schedule, it belongs in the classes whose names Schedule is 
# checking.

# This implementation cries out for a simple and obvious improvement, 
# one suggested by the pattern of the code. Instead of knowing 
# details about other classes, the Schedule should send them messages.

### Removing Unnecessary Dependencies ###

# The fact that the Schedule checks many class names to determine 
# what value to place in one variable suggests that the variable name 
# should be turned into a message, which in turn should be sent to 
# each incoming object.

#### Discovering the Schedulable Duck Type ####

# Figure 7.2 shows a sequence diagram for new code that removes the 
# check on class from the schedulable? method and alters the method 
# to instead send the lead_days message to its incoming target 
# argument. This change replaces an if statement that checks the 
# class of an object with a message sent to that same object. It 
# simplifies the code and pushes responsibility for knowing the 
# correct number of lead days into the last object that could 
# possibly know the correct answer, which is exactly where this 
# responsibility belongs.

# A close look at Figure 7.2 reveals something interesting. Notice 
# that this diagram contains a box labeled “the target.” The boxes on 
# sequence diagrams are meant to represent objects and are commonly 
# named after classes, as in “the Schedule” or “a Bicycle.” In Figure 
# 7.2, the Schedule intends to send lead_days to its target, but 
# target could be an instance of any of a number of classes. Because 
# target’s class is unknown, it’s not obvious how to label the box 
# for the receiver of this message.

# The easiest way to draw the diagram is to sidestep this issue by 
# labeling the box after the name of the variable and sending the 
# lead_days message to that “target” without being precise about its 
# class. The Schedule clearly does not care about target’s class, 
# instead it merely expects it to respond to a specific message. This 
# message-based expectation transcends class and exposes a role, one 
# played by all targets and made explicitly visible by the sequence 
# diagram.

# *
# The Schedule expects its target to behave like something that 
# understands lead_days, that is, like something that is “schedulable.
# ” You have discovered a duck type.

# **
#### Letting Objects Speak for Themselves ####

# Discovering and using this duck type improves the code by removing 
# the Schedule’s dependency on specific class names, which makes the 
# application more flexible and easier to maintain. However, Figure 7.
# 2 still contains unnecessary dependencies that should be removed.

# It’s easiest to illustrate these dependencies with an extreme 
# example. Imagine a StringUtils class that implements utility 
# methods for managing strings. You can ask StringUtils if a string 
# is empty by sending StringUtils.empty?(some_string).

# If you have written much object-oriented code you will find this 
# idea ridiculous. Using a separate class to manage strings is 
# patently redundant; strings are objects, they have their own 
# behavior, they manage themselves. Requiring that other objects know 
# about a third party, StringUtils, to get behavior from a string 
# complicates the code by adding an unnecessary dependency.

# This specific example illustrates the general idea that objects 
# should manage themselves; they should contain their own behavior. 
# If your interest is in object B, you should not be forced to know 
# about object A if your only use of it is to find things out about B.

# The sequence diagram in Figure 7.2 violates this rule. The 
# instigator is trying to ascertain if the target object is 
# schedulable. Unfortunately, it doesn’t ask this question of target 
# itself, it instead asks a third party, Schedule. Asking Schedule if 
# a target is schedulable is just like asking StringUtils if a string 
# is empty. It forces the instigator to know about and thus depend 
# upon the Schedule, even though its only real interest is in the 
# target.

# Just as strings respond to empty? and can speak for themselves, 
# targets should respond to schedulable?. The schedulable? method 
# should be added to the interface of the Schedulable role.

### Writing the Concrete Code ###

# The simplest way to get started is to separate the two decisions. 
# Pick an arbi- trary concrete class (for example, Bicycle) and 
# implement the schedulable? method directly in that class. Once you 
# have a version that works for Bicycle you can refactor your way to 
# a code arrangement that allows all Schedulables to share the 
# behavior.
# Figure 7.3 shows a sequence diagram where this new code is in 
# Bicycle. Bicycle now responds to messages about its own 
# “schedulability.”
# Before this change, every instigating object had to know about and 
# thus had a dependency on the Schedule. This change allows bicycles 
# to speak for themselves, freeing instigating objects to interact 
# with them without the aid of a third party.

############## Page 148 ##############
class Schedule
  def scheduled?(schedulable, start_date, end_date)
    puts  "This #{schedulable.class} " +
          "is not scheduled\n" +
          " between #{start_date} and #{end_date}"
  end
end

############## Page 149 ##############
class Bicycle
  attr_reader :schedule, :size, :chain, :tire_size

  # Inject the schedule and provide a default
  def initialize(args={})
    @schedule = args[:schedule] || Schedule.new
    # ...
  end

  # Return true if this bicycle is available
  # during this (now Bicycle specific) interval.
  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  # Return the schedule's answer
  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  # Return the number of lead_data before a bicycle
  # can be scheduled
  def lead_days
    1
  end

  # ...
end

require 'date'
starting = Date.parse("2020/03/07")
ending   = Date.parse("2020/03/14")

b = Bicycle.new
puts b.schedulable?(starting, ending)
# This Bicycle is not scheduled
#   betwee 2020-03-06 and 2020-03-14
#   => true

# This code hides knowledge of who the Schedule is and what the 
# Schedule does inside of Bicycle. Objects holding onto a Bicycle no 
# longer need know about the existence or behavior of the Schedule.


## Extracing the Abstraction ###

# The code above solves the first part of current problem in that it 
# decides what the schedulable? method should do, but Bicycle is not 
# the only kind of thing that is “schedulable.” Mechanic and Vehicle 
# also play this role and therefore need this behavior. It’s time to 
# rearrange the code so that it can be shared among objects of 
# different classes.

############## Page 150 ##############
module Schedulable
  attr_writer :schedule

  def schedule
    @schedule ||= ::Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  # includers may override
  def lead_days
    0
  end

end

# **
# Two things have changed from the code as it previously existed in 
# Bicycle. First, a schedule method (line 4) has been added. This 
# method returns an instance of the overall Schedule.
# Back in Figure 7.2 the instigating object depended on the Schedule, 
# which meant there might be many places in the application that 
# needed knowledge of the Schedule. In the next iteration, Figure 7.
# 3, this dependency was transferred to Bicycle, reducing its reach 
# into the application. Now, in the code above, the dependency on 
# Schedule has been removed from Bicycle and moved into the 
# Schedulable module, isolating it even further.

# **
# The second change is to the lead_days method (line 17). Bicycle’s 
# former implementation returned a bicycle specific number, the 
# module’s implementation now returns a more generic default of zero 
# days.
# Even if there were no reasonable application default for lead days, 
# the Schedulable module must still implement the lead_days method. 
# The rules for modules are the same as for classical inheritance. If 
# a module sends a message it must provide an implementation, even if 
# that implementation merely raises an error indicating that users of 
# the module must implement the method.

# Including this new module in the original Bicycle class, as shown 
# in the example below, adds the module’s methods to Bicycle’s 
# response set. The lead_days method is a hook that follows the 
# template method pattern. Bicycle overrides this hook (line 4) to 
# provide a specialization.

############## Page 151 ##############
class Bicycle
  include Schedulable

  def lead_days
    1
  end

  # ...
end

require 'date'
starting = Date.parse("2020/03/07")
ending   = Date.parse("2020/03/14")

b = Bicycle.new
puts b.schedulable?(starting, ending)
# This Bicycle is not scheduled
#    between 2020-03-06 and 2020-03-14
#  => true

# Moving the methods to the Schedulable module, including the module 
# and overriding lead_days, allows Bicycle to continue to behave 
# correctly. Additionally, now that you have created this module 
# other objects can make use of it to become Schedulable themselves. 
# They can play this role without duplicating the code.

# **
# The pattern of messages has changed from that of sending 
# schedulable? to a Bicycle to sending schedulable? to a Schedulable. 
# You are now committed to the duck type and the sequence diagram 
# shown in Figure 7.3 can be altered to look like the one in Figure 7.
# 4.

# Once you include this module in all of the classes that can be 
# scheduled, the pattern of code becomes strongly reminiscent of 
# inheritance. The following example shows Vehicle and Mechanic 
# including the Schedulable module and responding to the schedulable? 
# message.

############## Page 152 ##############
class Vehicle
  include Schedulable

  def lead_days
    3
  end

  # ...

end

class Mechanic
  include Schedulable

  def lead_days
    4
  end

  # ...
end

v = Vehicle.new
puts v.schedulable?(starting, ending)
# This Vehicle is not scheduled
#   between 2020-03-04 and 2020-03-14
#  => true

m = Mechanic.new
puts m.schedulable?(starting, ending)
# This Mechanic is not scheduled
#   between 2020-03-03 and 2020-03-14
#  => true

# **
# The code in Schedulable is the abstraction and it uses the template 
# method pattern to invite objects to provide specializations to the 
# algorithm it supplies. Schedulables override lead_days to supply 
# those specializations. When schedulable? arrives at any 
# Schedulable, the message is automatically delegated to the method 
# defined in the module.

# This may not fit the strict definition of classical inheritance, 
# but in terms of how the code should be written and how the messages 
# are resolved, it certainly acts like it. The coding techniques are 
# the same because method lookup follows the same path.
# This chapter has been careful to maintain a distinction between 
# classical inheritance and sharing code via modules. This is-a 
# versus behaves-like-a difference definitely matters, each choice 
# has distinct consequences. However, the coding techniques for these 
# two things are very similar and this similarity exists because both 
# techniques rely on automatic message delegation.

### Looking Up Methods ###

# Understanding the similarities between classical inheritance and 
# module inclusion is easier if you understand how object-oriented 
# languages, in general, and Ruby, in particular, find the method 
# implementation that matches a message send.

#### A Gross Oversimplification ####
# The search for a method begins in the class of the receiving 
# object. If this class does not implement the message, the search 
# proceeds to its superclass. From here on only superclasses matter, 
# the search proceeds up the superclass chain, looking in one 
# superclass after another, until it reaches the top of the hierarchy.
# Figure7.5

#### A More Accurate Explanation ####
# Figure 7.6
# The object hierarchy in Figure 7.6 looks much like the one from 
# Figure 7.5. It differs only in that Figure 7.6 shows the 
# Schedulable module highlighted between the Bicycle and Object 
# classes.
# Figure 7.6 shows the schedulable? message being sent to an instance 
# of MountainBike. To resolve this message, Ruby first looks for a 
# matching method in the MountainBike class. The search then proceeds 
# along the method lookup path, which now contains modules as well as 
# superclasses. An implementation of schedulable? is eventually found 
# in Schedulable, which lies in the lookup path between Bicycle and 
# Object.

#### A Very Nearly Complete Explanation ####
# It’s entirely possible for a hierarchy to contain a long chain of 
# superclasses, each of which includes many modules. When a single 
# class includes several different modules, the modules are placed in 
# the method lookup path in reverse order of module inclusion. 
# Thus, the methods of the last included module are encountered first 
# in the lookup path.
# This discussion has, until now, been about including modules into 
# classes via Ruby’s include keyword. As you have already seen, 
# including a module into a class adds the module’s methods to the 
# response set for all instances of that class. For example, in 
# Figure 7.6 the Schedulable module was included into the Bicycle 
# class, and, as a result, instances of MountainBike gain access to 
# the methods defined therein.
# However, it is also possible to add a module’s methods to a single 
# object, using Ruby’s extend keyword. Because extend adds the 
# module’s behavior directly to an object, extending a class with a 
# module creates class methods in that class and extending an 
# instance of a class with a module creates instance methods in that 
# instance. These two things are exactly the same; classes are, after 
# all, just plain old objects, and extend behaves the same for all.
# Finally, any object can also have ad hoc methods added directly to 
# its own personal “Singleton class.” These ad hoc methods are unique 
# to this specific object.
# Each of these alternatives adds to an object’s response set by 
# placing method definitions in specific and unambiguous places along 
# the method lookup path. Figure 7.7 illustrates the complete list of 
# possibilities.

### Inheriting Role Behavior ###
# Now that you’ve seen how to define a role’s shared code in a module 
# and how a module’s code gets inserted into the method lookup path, 
# you are equipped to write some truly frightening code. You can 
# create deeply nested class inheritance hierarchies and then include 
# these various modules at different levels of the hierarchy.

# You can write code that is impossible to understand, debug, or 
# extend.

# **
# This is powerful stuff, and dangerous in untutored hands. However, 
# because this very same power is what allows you to create simple 
# structures of related objects that elegantly fulfill the needs of 
# your application, your task is not to avoid these techniques but to 
# learn to use them for the right reasons, in the right places, in 
# the correct way.

## Writing Inheritable Code ##

# The usefulness and maintainability of inheritance hierarchies and 
# modules is in direct proportion to the quality of the code. More so 
# than with other design strategies, sharing inherited behavior 
# requires very specific coding techniques

# **
### Recognize the Antipatterns ###

# There are two antipatterns that indicate that your code might benefit from inheritance. 

# First, an object that uses a variable with a name like type or 
# category to determine what message to send to self contains two 
# highly related but slightly different types. This is a maintenance 
# nightmare; the code must change every time a new type is added. 
# Code like this can be rearranged to use classical inheritance by 
# putting the common code in an abstract superclass and creating 
# subclasses for the different types. This rearrangement allows you 
# to create new subtypes by adding new subclasses.
# These subclasses extend the hierarchy without changing the existing 
# code.

# Second, when a sending object checks the class of a receiving 
# object to determine what message to send, you have overlooked a 
# duck type. This is another maintenance nightmare; the code must 
# change every time you introduce a new class of receiver. In this 
# situation all of the possible receiving objects play a common role. 
# This role should be codified as a duck type and receivers should 
# implement the duck type’s interface. Once they do, the original 
# object can send one single message to every receiver, confident 
# that because each receiver plays the role it will understand the 
# common message.
# In addition to sharing an interface, duck types might also share 
# behavior. When they do, place the shared code in a module and 
# include that module in each class or object that plays the role.

### Insist on the Abstraction ###

# **
# All of the code in an abstract superclass should apply to every 
# class that inherits it. Superclasses should not contain code that 
# applies to some, but not all, subclasses. This restriction also 
# applies to modules: the code in a module must apply to all who use 
# it.

# Faulty abstractions cause inheriting objects to contain incorrect 
# behavior; attempts to work around this erroneous behavior will 
# cause your code to decay. When interacting with these awkward 
# objects, programmers are forced to know their quirks and into 
# dependencies that are better avoided.
# Subclasses that override a method to raise an exception like “does 
# not implement” are a symptom of this problem. While it is true that 
# expediency pays for all and that it is sometimes most cost 
# effective to arrange code in just this way, you should be reluctant 
# to do so. When subclasses override a method to declare that they do 
# not do that thing they come perilously close to declaring that they 
# are not that thing. Nothing good can come of this.
# If you cannot correctly identify the abstraction there may not be 
# one, and if no common abstraction exists then inheritance is not 
# the solution to your design problem.

# **
### Honor the Contract ###

# Subclasses agree to a contract; they promise to be substitutable 
# for their superclasses. Substitutability is possible only when 
# objects behave as expected and subclasses are expected to conform 
# to their superclass’s interface. They must respond to every message 
# in that interface, taking the same kinds of inputs and returning 
# the same kinds of outputs. They are not permitted to do anything 
# that forces others to check their type in order to know how to 
# treat them or what to expect of them.

# Where superclasses place restrictions on input arguments and return 
# values, subclasses can indulge in a slight bit of freedom without 
# violating their contract. Subclasses may accept input parameters 
# that have broader restrictions and may return results that have 
# narrower restrictions, all while remaining perfectly substitutable 
# for their superclasses.
# Subclasses that fail to honor their contract are difficult to use. 
# They’re “special” and cannot be freely substituted for their 
# superclasses. These subclasses are declaring that they are not 
# really a kind-of their superclass and cast doubt on the correctness 
# of the entire hierarchy.

# ------------------------------------------------------------------
# Liskov Substitution Principle (LSP)
# When you honor the contract, you are following the Liskov 
# Substitution Principle, which is named for its creator, Barbara 
# Liskov, and supplies the “L” in the SOLID design principles.

# Her principle states:
# Let q(x) be a property provable about objects x of type T. Then q(y)
# should be true for objects y of type S where S is a subtype of T.

# Mathematicians will instantly comprehend this statement; everyone 
# else should understand it to say that in order for a type system to 
# be same, subtypes must be substitutable for their supertypes.
# Following this principle creates applications where a subclass can 
# be used anywhere its superclass would do, and where objects that 
# include modules can be trusted to interchangeably play the module’s 
# role.
# ------------------------------------------------------------------

# **
### Use the Template Method Pattern ###

# The fundamental coding technique for creating inheritable code is 
# the template method pattern. This pattern is what allows you to 
# separate the abstract from the concrete. The abstract code 
# defines the algorithms and the concrete inheritors of that 
# abstraction contribute specializations by overriding these template 
# methods.

# The template methods represent the parts of the algorithm that vary 
# and creating them forces you to make explicit decisions about what 
# varies and what does not.