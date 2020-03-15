# Combining Objects with Comprehension #

# Composition is the act of combining distinct parts into a complex 
# whole such that the whole becomes more than the sum of its parts. 
# Music, for example, is composed.

# You may not think of your software as music but the analogy is apt. 
# The musical score of Beethoven’s Fifth Symphony is a long list of 
# distinct and independent notes. You need hear them only once to 
# understand that while it contains the notes, it is not the notes. 
# It is something more.

# You can create software this same way, by using object-oriented 
# composition to combine simple, independent objects into larger, 
# more complex wholes. In composition, the larger object is 
# connected to its parts via a has-a relationship. A bicycle has 
# parts. Bicycle is the containing object, the parts are contained 
# within a bicycle. Inherent in the definition of composition is the 
# idea that, not only does a bicycle have parts, but it communicates 
# with them via an interface. Part is a role and bicycles are happy 
# to collaborate with any object that plays the role.

## Composing a Bicycle of Parts ##

# This section takes Chapter 6 example and moves it through several 
# refactorings, gradually replacing inheritance with composition.