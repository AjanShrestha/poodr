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

# **
### Knowing What to Test ###
# Most programmers write too many tests. This is not always obvious 
# because in many cases the cost of these unnecessary tests is so 
# high that the programmers involved have given up testing 
# altogether. It’s not that they don’t have tests. They have a big, 
# but out-of-date test suite; it just never runs. One simple way to 
# get better value from tests is to write fewer of them. The safest 
# way to accomplish this is to test everything just once and in the 
# proper place.

# Removing duplication from testing lowers the cost of changing tests 
# in reaction to application changes, and putting tests in the right 
# place guarantees they’ll be forced to change only when absolutely 
# necessary. Distilling your tests to their essence requires having a 
# very clear idea about what you intend to test, one that can be 
# derived from design principles you already know.

# **
# Think of an object-oriented application as a series of messages 
# passing between a set of black boxes. Dealing with every object as 
# a black box puts constraints on what others are permitted to know 
# and limits the public knowledge about any object to the messages 
# that pierce its boundaries.
# Well-designed objects have boundaries that are very strong. Each is 
# like the space capsule shown in Figure 9.1. Nothing on the outside 
# can see in, nothing on the inside can see out and only a few 
# explicitly agreed upon messages can pass through the predefined 
# airlocks.
# This willful ignorance of the internals of every other object is at 
# the core of design. Dealing with objects as if they are only and 
# exactly the messages to which they respond lets you design a 
# changeable application, and it is your understanding of the 
# importance of this perspective that allows you to create tests that 
# provide maximum benefit at minimum cost.
# The design principles you are enforcing in your application apply 
# to your tests as well. Each test is merely another application 
# object that needs to use an existing class. The more the test gets 
# coupled to that class, the more entangled the two become and the 
# more vulnerable the test is to unnecessarily being forced to change.
# Not only should you limit couplings, but the few you allow should 
# be to stable things. The most stable thing about any object is its 
# public interface; it logically follows that the tests you write 
# should be for messages that are defined in public interfaces. The 
# most costly and least useful tests are those that blast holes in an 
# object’s containment walls by coupling to unstable internal 
# details. These over-eager tests prove nothing about the overall 
# correctness of an application but nonetheless raise costs because 
# they break with every refactoring of underlying class.

# Tests should concentrate on the incoming or outgoing messages that 
# cross an object’s boundaries. The incoming messages make up the 
# public interface of the receiving object. The outgoing messages, by 
# definition, are incoming into other objects and so are part of some 
# other object’s interface, as illustrated in Figure 9.2.
# In Figure 9.2, messages that are incoming into Foo make up Foo’s 
# public interface. Foo is responsible for testing its own interface 
# and it does so by making assertions about the results that these 
# messages return. Tests that make assertions about the values that 
# messages return are tests of state. Such tests commonly assert that 
# the results returned by a message equal an expected value.
# Figure 9.2 also shows Foo sending messages to Bar. A message sent 
# by Foo to Bar is outgoing from Foo but incoming to Bar. This 
# message is part of Bar’s public interface and all tests of state 
# should thus be confined to Bar. Foo need not, and should not, test 
# these outgoing messages for state. The general rule is that objects 
# should make assertions about state only for messages in their own 
# public interfaces. Following this rule confines tests of message 
# return values to a single place and removes unnecessary 
# duplication, DRYing out your tests and lowering maintenance costs.

# The fact that you need not test outgoing messages for state does 
# not mean outgoing messages need no tests at all. There are two 
# flavors of outgoing messages, and one of them requires a different 
# kind of test.
# Some outgoing messages have no side effects and thus matter only to 
# their senders. The sender surely cares about the result it gets 
# back (why else send the message?), but no other part of the 
# application cares if the message gets sent. Outgoing messages like 
# this are known as queries and they need not be tested by the 
# sending object. Query messages are part of the public interface of 
# their receiver, which already implements every necessary test of 
# state.
# However, many outgoing messages do have side effects (a file gets 
# written, a data- base record is saved, an action is taken by an 
# observer) upon which your application depends. These messages are 
# commands and it is the responsibility of the sending object to 
# prove that they are properly sent. Proving that a message gets sent 
# is a test of behavior, not state, and involves assertions about the 
# number of times, and with what arguments, the message is sent.

# **
# Here, then, are the guidelines for what to test: 
#   Incoming messages should be tested for the state they return. 
#   Outgoing command messages should be tested to ensure they get 
#     sent. 
#   Outgoing query messages should not be tested.

# As long as your application’s objects deal with one another 
# strictly via public interfaces, your tests need know nothing more. 
# When you test this minimal set of messages, no change in the 
# private behavior of any object can affect any test. When you test 
# outgoing command messages only to prove they get sent, your loosely 
# coupled tests can tolerate application changes without being forced 
# to change in turn. As long as the public interfaces remain stable, 
# you can write tests once and they will keep you safe forever.

# **
### Knowing When to Test ###
# You should write tests first, whenever it makes sense to do so.
# Unfortunately, judging when it makes sense to do so can be a 
# challenge for novice designers, rendering this advice less than 
# helpful. Novices often write code that is far too coupled; they 
# combine unrelated responsibilities and bind many dependencies into 
# every object. Their applications are tightly woven tapestries of 
# entangled code where no object lives in isolation. It is very hard 
# to retroactively test these applications because tests are reuse 
# and this code can’t be reused.

# Writing tests first forces a modicum of reusability to be built 
# into an object from its inception; it would otherwise be impossible 
# to write tests at all. Therefore, novice designers are best served 
# by writing test-first code. Their lack of design skills may make 
# this bafflingly difficult but if they persevere they will at least 
# have testable code, something that may not otherwise be true.
# Be warned, however, that writing tests first is no substitute for 
# and does not guarantee a well-designed application. The reusability 
# that results from test-first is an improvement over nothing at all 
# but the resulting application can still fall far short of good 
# design. Well-intentioned novices often write expensive, duplicative 
# tests around messy, tightly coupled code. It is an unfortunate 
# truth that the most complex code is usually written by the least 
# qualified person. This does not reflect an innate complexity of the 
# underlying task, rather a lack of experience on the part of the 
# programmer. Novice programmers don’t yet have the skills to write 
# simple code.

# The overcomplicated applications these novices produce should be 
# viewed as triumphs of perseverance; it’s a miracle these 
# applications work at all. The code is hard. The applications are 
# difficult to change and every refactoring breaks all the tests. 
# This high cost of change can easily start a downward productivity 
# spiral that is discouraging for all concerned. Changes cascade 
# throughout the application, and the maintenance cost of tests makes 
# them seem costly relative to their worth.
# If you are a novice and in this situation, it’s important to 
# sustain faith in the value of tests. Done at the correct time and 
# in the right amounts, testing, and writing code test-first, will 
# lower your overall costs. Gaining these benefits requires applying 
# object-oriented design principles everywhere, both to the code of 
# your application and to the code in your tests. Your new-found 
# knowledge of design already makes it easier to write testable code. 
# Because well-designed applications are easy to change, and 
# well-designed tests may very well avoid change altogether, these 
# overall design improvements pay off dramatically.

# Experienced designers garner subtler improvements from 
# testing-first. It’s not that they can’t benefit from it or that 
# they’ll never discover something unexpected by following its 
# dictates, rather that the gains accrued from forced reuse are ones 
# they already have. These programmers already write loosely coupled, 
# reusable code; tests add value in other ways.
# It is not unheard of for experienced designers to “spike” a 
# problem, that is, to do experiments where they just write code. 
# These experiments are exploratory, for problems about whose 
# solution they are uncertain. Once clarity is gained and a design 
# suggests itself, these programmers then revert to test-first for 
# production code.

# Your overall goal is to create well-designed applications that have 
# acceptable test coverage. The best way to reach this goal varies 
# according to the strengths and experience of the programmer.

# This license to use your own judgment is not permission to skip 
# testing. Poorly designed code without tests is just legacy code 
# that can’t be tested. Don’t overestimate your strengths and use an 
# inflated self-view as an excuse to avoid tests. While it sometimes 
# makes sense to write a bit of code the old fashioned way, you 
# should err on the side of test-first.

# **
### Knowing How to Test ###
# Anyone can create a new Ruby testing framework and sometimes it 
# seems that everyone has. The next shiny new framework may contain a 
# feature that you just can’t live without; if you understand the 
# costs and benefits, feel free to choose any framework that suits 
# you.

# However, there are many good reasons to stay within the testing 
# mainstream. The frameworks with the most use have the best support. 
# They are speedily updated to ensure compatibility with new releases 
# of Ruby (and of Rails) and so present no obstacle to keeping 
# current. Their large user base biases them towards maintaining 
# backward compatibility; it’s unlikely they’ll change in such a way 
# as to force a rewrite of all your tests. And because they are 
# widely adopted, it’s easy to find programmers who have experience 
# using them.
# As of this writing, the mainstream frameworks are MiniTest, from 
# Ryan Davis and seattle.rb and bundled with Ruby as of version 1.9, 
# and RSpec, from David Chelimsky and the RSpec team. These 
# frameworks have different philosophies and while you may naturally 
# lean towards one or the other, both are excellent choices.

# Not only must you choose a framework, you must grapple with 
# alternative styles of testing: 
#   Test Driven Development (TDD) and 
#   Behavior Driven Development (BDD). 
# Here the decision is not so clear-cut. TDD and BDD may appear to be 
# in opposition but they are best viewed as on a continuum like 
# Figure 9.3, where your values and experience dictate the choice of 
# where to stand.
# Both styles create code by writing tests first. BDD takes an 
# outside-in approach, creating objects at the boundary of an 
# application and working its way inward, mocking as necessary to 
# supply as-yet-unwritten objects. TDD takes an inside-out approach, 
# usually starting with tests of domain objects and then reusing 
# these newly created domain objects in the tests of adjacent layers 
# of code.
# Past experience or inclination may render one style more suitable 
# for you than the other, but both are completely acceptable. Each 
# has costs and benefits.

# When testing, it’s useful to think of your application’s objects as 
# divided into two major categories. The first category contains the 
# object that you’re testing, referred to from now on as the object 
# under test. The second category contains everything else.
# Your tests must obviously know things about the first category, 
# that is, about the object under test, but they should remain as 
# ignorant as possible about the second. Pretend that the rest of the 
# application is opaque, that the only information available during 
# the test is that which can be gained from looking at the object 
# under test.
# Once you dial your testing focus down to the specific object under 
# test, you’ll need to choose a testing point-of-view. Your tests 
# could stand completely inside of the object under test, with 
# effective access to all of its internals. This is a bad idea, 
# however, because it allows knowledge that should be private to the 
# object to leak into the tests, increasing coupling between them and 
# raising the likelihood that changes to code will require changes in 
# tests. It’s better for tests to assume a viewpoint that sights 
# along the edges of the object under test, where they can know only 
# about messages that come and go.

# ------------------------------------------------------------
# MiniTest Framework
# The tests in this chapter are written using MiniTest. This is not 
# an endorsement of one framework over another, rather a recognition 
# of the fact that examples written in MiniTest will run anywhere 
# Ruby 1.9 or above is installed. You can duplicate and experiment 
# with these examples without installing additional software.

# By the time you read this chapter MiniTest may have changed. 
# Perfect strangers may well have improved this software and given 
# you those improvements free of charge; such is the life of the open 
# source developer. Regardless of how MiniTest may have evolved, the 
# principles illustrated below hold true. Don’t get distracted by 
# changes in syntax; concentrate on understanding the underlying 
# goals of the tests. Once you understand these goals, you can 
# achieve them via any testing framework.
# ------------------------------------------------------------