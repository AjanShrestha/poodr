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

## Intentional Testing ##

# The most common arguments for having tests are that they reduce 
# bugs and provide documentation, and that writing tests first 
# improves application design.

# **
# These benefits, however valid, are proxies for a deeper goal. The 
# true purpose of testing, just like the true purpose of design, is 
# to reduce costs. If writing, maintaining, and running tests 
# consumes more time than would otherwise be needed to fix bugs, 
# write documentation, and design applications tests are clearly not 
# worth writing and no rational person would argue otherwise.
# It is common for programmers who are new to testing to find 
# themselves in the unhappy state where the tests they write do cost 
# more than the value those tests provide, and who therefore want to 
# argue about the worth of tests. These are programmers who believed 
# themselves highly productive in their former test-not lives but who 
# have crashed into the test-first wall and stumbled to a halt. Their 
# attempts at test-first programming result in less output, and their 
# desire to regain productivity drives them to revert to old habits 
# and forgo writing tests.
# The solution to the problem of costly tests, however, is not to 
# stop testing but instead to get better at it. Getting good value 
# from tests requires clarity of intention and knowing what, when, 
# and how to test.

# ***
### Knowing Your Intentions ###
# Testing has many potential benefits, some obvious, others more obscure. A thorough understanding of these benefits will increase your motivation to achieve them.

#### Finding Bugs ####
# Finding faults, or bugs, early in the development process yields 
# big dividends. Not only is it easier to find and fix a bug nearer 
# in time to its creation, but getting the code right earlier rather 
# than later can have unexpected positive effects on the resulting 
# design. Knowing that you can (or can’t) do something early on may 
# cause you to choose alternatives in the present that alter the 
# design options available in the future. Also, as code accumulates, 
# embedded bugs acquire dependencies. Fixing these bugs late in the 
# process may necessitate changing a lot of dependent code. Fixing 
# bugs early always lowers costs.

#### Supplying Documentation ####
# Tests provide the only reliable documentation of design. The story 
# they tell remains true long after paper documents become obsolete 
# and human memory fails. Write your tests as if you expect your 
# future self to have amnesia. Remember that you will forget; write 
# tests that remind you of the story once you have.

#### Deferring Design Decisions ####
# Tests allow you to safely defer design decisions. As your design 
# skills improve you will begin to write applications that are 
# sprinkled with places where you know the design needs something but 
# you don’t yet have enough information to know exactly what. These 
# are the places where you are awaiting additional information, 
# valiantly resisting the forces that compel you to commit to a 
# specific design.
# These “pending” decision points are often coded as slightly 
# embarrassing, extremely concrete hacks hidden behind totally 
# presentable interfaces. This situation occurs when you are aware of 
# just one concrete case in the present but you fully expect new 
# cases to arrive in the near future. You know that at some point you 
# will be better served by code that handles these many concrete 
# cases as a single abstraction, but right now you don’t have enough 
# information to anticipate what that abstraction will be.
# When your tests depend on interfaces you can refactor the 
# underlying code with reckless abandon. The tests verify the 
# continued good behavior of the interface and changes to the 
# underlying code do not force rewrites of the tests. Intentionally 
# depending on interfaces allows you to use tests to put off design 
# decisions safely and without penalty.

#### Supporting Abstractions ####
# When more information finally arrives and you make the next design 
# decision, you’ll change the code in ways that increase its level of 
# abstraction. Herein lies another of the benefits of tests on design.
# Good design naturally progresses toward small independent objects 
# that rely on abstractions. The behavior of a well-designed 
# application gradually becomes the result of interactions among 
# these abstractions. Abstractions are wonderfully flexible design 
# components but the improvements they provide come at one slight 
# cost: While each individual abstraction might be easy to 
# understand, there is no single place in the code that makes obvious 
# the behavior of the whole.
# As the code base expands and the number of abstractions grows, 
# tests become increasingly necessary. There is a level of design 
# abstraction where it is almost impossible to safely make any change 
# unless the code has tests. Tests are your record of the interface 
# of every abstraction and as such they are the wall at your back. 
# They let you put off design decisions and create abstractions to 
# any useful depth.

#### Exposing Design Flaws ####
# The next benefit of tests is that they expose design flaws in the 
# underlying code. If a test requires painful setup, the code expects 
# too much context. If testing one object drags a bunch of others 
# into the mix, the code has too many dependencies. If the test is 
# hard to write, other objects will find the code difficult to reuse.
# Tests are the canary in the coal mine; when the design is bad, 
# testing is hard.
# The inverse, however, is not guaranteed to be true. Costly tests do 
# not necessarily mean that the application is poorly designed. It is 
# quite technically possible to write bad tests for well-designed 
# code. Therefore, for tests to lower your costs, both the underlying 
# application and the tests must be well-designed.

# Your goal is to gain all of the benefits of testing for the least 
# cost possible. The best way to achieve this goal is to write 
# loosely coupled tests about only the things that matter.