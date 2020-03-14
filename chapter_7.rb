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