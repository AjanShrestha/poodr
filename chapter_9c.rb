## Testing Private Methods ##
# Sometimes the object under test sends messages to itself. Messages 
# sent to self invoke methods that are defined in the receiver’s 
# private interface. These private messages are like proverbial trees 
# falling in empty forests; they do not exist, at least as far as the 
# rest of your application is concerned. Because sends of private 
# methods cannot be seen from outside of the black box of the object 
# under test, in the pristine world of idealized design they need not 
# be tested.

# However, the real world is not so neat and this simple rule does 
# not completely suffice. Dealing with private methods requires 
# judgment and flexibility.

### Ignoring Private Methods During Tests ###
# There are many excellent reasons to omit tests of private methods.
#   First, such tests are redundant. Private methods are hidden 
#     inside the object under test and their results cannot be seen 
#     by others. These private methods are invoked by public methods 
#     that already have tests. A bug in a private method can 
#     certainly break the overall application but this failure will 
#     always be exposed by an existing test. Testing private methods 
#     is never necessary.
#   Second, private methods are unstable. Tests of private methods 
#     are therefore coupled to application code that is likely to 
#     change. When the application changes the tests will be forced 
#     to change in turn. It’s easy to create a situation where 
#     precious time is spent performing ongoing maintenance on 
#     unnecessary tests.
#   Finally, testing private methods can mislead others into using 
#     them. Tests provide documentation about the object under test. 
#     They tell a story about how it expects to interact with the 
#     world at large. Including private methods in this story 
#     distracts the readers from its main purpose and encourages them 
#     to break encapsulation and to depend on these methods. Your 
#     tests should hide private methods, not expose them.

### Removing Private Methods from the Class Under Test ###
# One way to sidestep this entire problem is to avoid private methods 
# altogether. If you have no private methods, you need not be 
# concerned for their tests.

# **
# An object with many private methods exudes the design smell of 
# having too many responsibilities. If your object has so many 
# private methods that you dare not leave them untested, consider 
# extracting the methods into new object. The extracted methods form 
# the core of the responsibilities of the new object and so make up 
# its public interface, which is (theoretically) stable and thus safe 
# to depend upon.
# This strategy is a good one, but unfortunately is only truly 
# helpful if the new interface is indeed stable. Sometimes the new 
# interface is not, and it is at this point that theory and practice 
# part ways. This new public interface will be exactly as stable (or 
# as unstable) as was the original private interface. Methods don’t 
# magically become more reliable just because they got moved. It is 
# costly to couple to unstable methods—regardless of whether they are 
# portrayed as public or private.

### Choosing to Test a Private Method ###
# Times of great uncertainly call for drastic measures. It is 
# therefore occasionally defensible to fling a bit of smelly code 
# into place and hide the mess until better information arrives. 
# Hiding messes is easily done; just wrap the offending code in a 
# private method.

# If you create a mess and never fix it your costs will eventually go 
# up, but in the short term, for the right problem, having enough 
# confidence to write embarrassing code can save money. When your 
# intention is to defer a design decision, do the simplest thing that 
# solves today’s problem. Isolate the code behind the best interface 
# you can conceive and hunker down and wait for more information.

# Applying this strategy can result in private methods that are 
# wildly unstable. Once you’ve made this leap it’s reasonable to 
# consider compounding your sins by testing these unstable methods. 
# The application code is ugly and will undergo frequent change; the 
# risk of breaking something is ever-present. These tests are costly 
# and will likely be forced to change in lock-step with the 
# underlying code, but every other option for keeping things running 
# may be more expensive.

# These tests of private methods aren’t necessary in order to know 
# that a change broke something, the public interface tests still 
# serve that purpose admirably. Tests of private methods produce 
# error messages that directly pinpoint the failing parts of private 
# code. These more specific errors are tight couplings that increase 
# maintenance costs, but they make it easier to understand the 
# effects of changes and so they take some of the pain out of 
# refactoring complex private code.

# Reducing the barriers to refactoring is important, because refactor 
# you will. That’s the whole point. The mess is temporary, you intend 
# to refactor out of it. As more design information arrives, these 
# private methods will improve. Once the fog clears and a design 
# reveals itself, the methods will become more stable. As stability 
# improves, the cost of maintaining and the need for tests will go 
# down. Eventually it will be possible to extract the private methods 
# into a separate class and safely expose them to the world.

# **
# The rules-of-thumb for testing private methods are thus: 
#   Never write them, and if you do, never ever test them, unless of 
#     course it makes sense to do so. Therefore, be biased against 
#     writing these tests but do not fear to do so if this would 
#     improve your lot.