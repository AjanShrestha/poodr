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