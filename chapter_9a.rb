# Designing Cost-Effective Tests #

# Writing changeable code is an art whose practice relies on three different skills.

# **
# First, you must understand object-oriented design. Poorly designed 
# code is naturally difficult to change. From a practical point of 
# view, changeability is the only design metric that matters; code 
# that’s easy to change is well-designed. Because you have read this 
# far it’s only fair to assume that your efforts will pay off and 
# that you have acquired a foundation from which to begin the 
# practice of designing changeable code.

# **
# Second, you must be skilled at refactoring code. Not in the casual 
# sense of “go into the application and fling some things around,” 
# but in the real, grown-up, bullet-proof sense defined by Martin 
# Fowler in Refactoring: Improving the Design of Existing Code:
#   Refactoring is the process of changing a software system in such 
#   a way that it does not alter the external behavior of the code 
#   yet improves the internal structure.
# Notice the phrase does not alter the external behavior of the code. 
# Refactoring, as formally defined, does not add new behavior, it 
# improves existing structure. It’s a precise process that alters 
# code via tiny, crab-like steps and carefully, incrementally, and 
# unerringly transforms one design into another.
# Good design preserves maximum flexibility at minimum cost by 
# putting off decisions at every opportunity, deferring commitments 
# until more specific requirements arrive. When that day comes, 
# refactoring is how you morph the current code structure into one 
# that will accommodate the new requirements. New features will be 
# added only after you have successfully refactored the code.
# If your refactoring skills are weak, improve them. The need for 
# ongoing refactoring is an outgrowth of good design; your design 
# efforts will pay full dividends only when you can refactor with 
# ease.

# Finally, the art of writing changeable code requires the ability to 
# write high-value tests. Tests give you confidence to refactor 
# constantly. Efficient tests prove that altered code continues to 
# behave correctly without raising overall costs. Good tests weather 
# code refactorings with aplomb; they are written such that changes 
# to the code do not force rewrites of the tests.
# Writing tests that can perform this trick is a matter of design

# An understanding of object-oriented design, good refactoring 
# skills, and the ability to write efficient tests form a 
# three-legged stool upon which changeable code rests. Well-designed 
# code is easy to change, refactoring is how you change from one 
# design to the next, and tests free you to refactor with impunity.