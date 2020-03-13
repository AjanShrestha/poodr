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