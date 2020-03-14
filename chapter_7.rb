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
