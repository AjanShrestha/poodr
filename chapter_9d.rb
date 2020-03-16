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