# Acquiring Behavior Through Inheritance

## Understanding Classical Inheritance ##

# The idea of inheritance may seem complicated but as with all 
# complexity, there’s a simplifying abstraction. Inheritance is, at 
# its core, a mechanism for automatic message delegation. It defines 
# a forwarding path for not-understood messages. It creates 
# relationships such that, if one object cannot respond to a received 
# message, it delegates that message to another. You don’t have to 
# write code to explicitly delegate the message, instead you define 
# an inheritance relationship between two objects and the forwarding 
# happens automatically.

# In classical inheritance these relationships are defined by 
# creating subclasses. Messages are forwarded from subclass to 
# superclass; the shared code is defined in the class hierarchy.

# The term classical is a play on the word class, not a nod to an 
# archaic technique, and it serves to distinguish this superclass/
# subclass mechanism from other inheritance techniques. JavaScript, 
# for example, has prototypical inheritance and Ruby has modules 
# (more on modules in the next chapter), both of which also provide a 
# way to share code via automatic delegation of messages.


## Recognizing Where to Use Inheritance ##

### Starting with a Concrete Class ###
# Bikes have an overall size, a handlebar tape color, a tire size, 
# and a chain type. Tires and chains are integral parts and so spares 
# must always be taken. Handlebar tape may seem less necessary, but 
# in real life it is just as required. No self-respecting cyclist 
# would tolerate dirty or torn bar tape; mechanics must carry spare 
# tape in the correct, matching color.

############## Page 107 ##############
class Bicycle
  attr_reader :size, :tape_color

  def initialize(args)
    @size       = args[:size]
    @tape_color = args[:tape_color]
  end

  # every bike has the same defaults for
  # tire and chain size
  def spares
    {
      chain:        '10-speed',
      tire_size:    '23',
      tape_color:   tape_color
    }
  end

  # Many other methods...
end

bike = Bicycle.new(
  size:       'M',
  tape_color: 'red'
)
puts bike.size      # -> 'M'
puts bike.spares
# -> {:tire_size    => "23",
#     :chain        => "10-speed",
#     :tape_color   => "red"}


# Bicycle instances can respond to the spares, size, and tape_color 
# messages and a Mechanic can figure out what spare parts to take by 
# asking each Bicycle for its spares. Despite the fact that the 
# spares method commits the sin of embedding default strings directly 
# inside itself, the above code is fairly reasonable. 

# This class works just fine until something changes. Imagine that 
# FastFeet begins to lead mountain bike trips.

# Mountain bikes and road bikes are much alike but there are clear 
# differences between them. Mountain bikes are meant to be ridden on 
# dirt paths instead of paved roads. They have sturdy frames, fat 
# tires, straight-bar handlebars (with rubber hand grips instead of 
# tape), and suspension. The bicycle front suspension only, but some 
# mountain bikes also have rear, or “full” suspension.

# Much of the behavior that you need already exists; mountain bikes 
# are definitely bicycles. They have an overall bike size and a chain 
# and tire size. The only differences between road and mountain bikes 
# are that road bikes need handlebar tape and mountain bikes have 
# suspension.

### Embedding Multiple Types ###

# When a preexisting concrete class contains most of the behavior you need, it’s tempting to solve this problem by adding code to that class. 

############## Page 110 ##############
class Bicycle
  attr_reader :style, :size, :tape_color,
              :front_shock, :rear_shock
  
  def initialize(args)
    @style       = args[:style]
    @size        = args[:size]
    @tape_color  = args[:tape_color]
    @front_shock = args[:front_shock]
    @rear_shock  = args[:rear_shock]
  end

  # checking 'style' starts down a slippery slope
  def spares
    if style == :road
      {
        chain:        '10-speed',
        tire_size:    '23',         # millimeters
        tape_color:   tape_color
      }
    else
      {
        chain:        '10-speed',
        tire_size:    '2.1',        # inches
        rear_shock:   rear_shock
      }
    end
  end
end

bike = Bicycle.new(
  style:        :mountain,
  size:         'S',
  front_shock:  'Manitou',
  rear_shock:   'Fox'
)

puts bike.spares
# -> {:tire_size    =>"2.1",
#     :chain        =>"10-speed",
#     :rear_shock   =>"Fox"}


# This example is simply a detour that illustrates an antipattern, 
# that is, a common pattern that appears to be beneficial but is 
# actually detrimental, and for which there is a well-known 
# alternative.


# This code makes decisions about spare parts based on the value held 
# in style; structuring the code this way has many negative 
# consequences. If you add a new style you must change the if 
# statement. If you write careless code where the last option is the 
# default (as does the code above) an unexpected style will do 
# something but perhaps not what you expect. Also, the spares method 
# started out containing embedded default strings, some of these 
# strings are now duplicated on each side of the if statement.

# Bicycle has an implied public interface that includes spares, size, 
# and all the individual parts. The size method still works, spares 
# generally works, but the parts methods are now unreliable. It’s 
# impossible to predict, for any specific instance of Bicycle, 
# whether a specific part has been initialized. Objects holding onto 
# an instance of Bicycle may, for example, be tempted to check style 
# before sending it tape_color or rear_shock.
# The code wasn’t great to begin with; this change did nothing to 
# improve it.
# The initial Bicycle class was imperfect but its imperfections were 
# hidden—encapsulated within the class. These new flaws have broader 
# consequences. Bicycle now has more than one responsibility, 
# contains things that might change for different reasons, and cannot 
# be reused as is.

# This code contains an if statement that checks an attribute that 
# holds the category of self to determine what message to send to s
# elf. This should bring back memories of a pattern discussed in the 
# previous chapter on duck typing, where you saw an if statement that 
# checked the class of an object to determine what message to send to 
# that object.
# In both of these patterns an object decides what message to send 
# based on a category of the receiver. You can think of the class of 
# an object as merely a specific case of an attribute that holds the 
# category of self ; considered this way, these patterns are the 
# same. In each case if the sender could talk it would be saying “I 
# know who you are and because of that I know what you do.” This 
# knowledge is a dependency that raises the cost of change.

# Be on the lookout for this pattern. While sometimes innocent and 
# occasionally defensible, its presence might be exposing a costly 
# flaw in your design. Here the pattern indicates a missing subtype, 
# better known as a subclass.

### Finding the Embedded Types ###

# The if statement in the spares method above switches on a variable 
# named style, but it would have been just as natural to call that 
# variable type or category. Variables with these kinds of names are 
# your cue to notice the underlying pattern. Type and category are 
# words perilously similar to those you would use when describing a 
# class. After all, what is a class if not a category or type?

# The style variable effectively divides instances of Bicycle into 
# two different kinds of things. These two things share a great deal 
# of behavior but differ along the style dimension. Some of Bicycle’s 
# behavior applies to all bicycles, some only to road bikes, and some 
# only to mountain bikes. This single class contains several 
# different, but related, types.

# This is the exact problem that inheritance solves; that of highly 
# related types that share common behavior but differ along some 
# dimension.

### Choosing Inheritance ###

# It goes without saying that objects receive messages. No matter how 
# complicated the code, the receiving object ultimately handles any 
# message in one of two ways. It either responds directly or it 
# passes the message on to some other object for a response.

# Inheritance provides a way to define two objects as having a 
# relationship such that when the first receives a message that it 
# does not understand, it automatically forwards, or delegates, the 
# message to the second. It’s as simple as that.

# Many object-oriented languages sidestep these complications by 
# providing single inheritance, whereby a subclass is allowed only 
# one parent superclass. Ruby does this; it has single inheritance. A 
# superclass may have many subclasses, but each subclass is permitted 
# only one superclass.

# Message forwarding via classical inheritance takes place between classes.

# Even if you have never explicitly created a class hierarchy of your 
# own, you use inheritance. When you define a new class but do not 
# specify its superclass, Ruby automatically sets your new class’s 
# superclass to Object. Every class you create is, by definition, a 
# subclass of something.

# You also already benefit from automatic delegation of messages to 
# superclasses. When an object receives a message it does not 
# understand, Ruby automatically for- wards that message up the 
# superclass chain in search of a matching method implementation.

# The fact that unknown messages get delegated up the superclass 
# hierarchy implies that subclasses are everything their superclasses 
# are, plus more. An instance of String is a String, but it’s also an 
# Object. 

# Every String is assumed to contain Object’s entire public interface 
# and must respond appropriately to any message defined in that 
# interface. Subclasses are thus specializations of their 
# superclasses.

# The current Bicycle example embeds multiple types inside the class. 
# It’s time to abandon this code and revert to the original version 
# of Bicycle. Perhaps mountain bikes are a specialization of Bicycle; 
# perhaps this design problem can be solved using inheritance.


## Misapplying Inheritance ##

# Under the premise that the journey is more useful than the 
# destination, and that experi- encing common mistakes by proxy is 
# less painful than experiencing them in person, this next section 
# continues to show code that is unworthy of emulation. 

############## Page 115 ##############
class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock  = args[:front_shock]
    @rear_shock   = args[:rear_shock]
    super(args)
  end

  def spares
    super.merge(rear_shock: rear_shock)
  end
end

# Jamming the new MountainBike class directly under the existing 
# Bicycle class was blindly optimistic, and, predictably, running the 
# code exposes several flaws. Instances of MountainBike have some 
# behavior that just doesn’t make sense. The following example 
# shows what happens if you ask a MountainBike for its size and 
# spares. It reports its size correctly but says that it has skinny 
# tires and implies that it needs handlebar tape, both of which are 
# incorrect.

############## Page 115 ##############
mountain_bike = MountainBike.new(
  size:          'S',
  front_shock:  'Manitou',
  rear_shock:   'Fox'
)

puts mountain_bike.size  # -> 'S

puts mountain_bike.spares
# -> {:tire_size    => "23",        <- wrong!
#     :chain        => "10-speed",
#     :tape_color   => nil,         <- not applicable
#     :front_shock  => 'Manitou'
#     :rear_shock   => "Fox"}

# It comes as no surprise that instances of MountainBike contain a 
# confusing mishmash of road and mountain bike behavior. The Bicycle 
# class is a concrete class that was not written to be subclassed. It 
# combines behavior that is general to all bicycles with behav- ior 
# that is specific to road bikes. When you slam MountainBike under 
# Bicycle, you inherit all of this behavior—the general and the 
# specific, whether it applies or not.

# The Bicycle class contains behavior that is appropriate for both a 
# peer and a par- ent of MountainBike. Some of the behavior in 
# Bicycle is correct for MountainBike, some is wrong, and some 
# doesn’t even apply. As written, Bicycle should not act as the 
# superclass of MountainBike.

# **
# Because design is evolutionary, this situation arises all the time. 
# The problem here started with the names of these classes.


## Finding the Abstraction ##

# In the beginning, there was one idea, a bicycle, and it was modeled 
# as a single class, Bicycle. The original designer chose a generic 
# name for an object that was actually slightly more specialized. The 
# existing Bicycle class doesn’t represent just any kind of bicycle, 
# it represents a specific kind—a road bike.

# However, now that MountainBike exists, Bicycle’s name is 
# misleading. These two class names imply inheritance; you 
# immediately expect MountainBike to be a specialization of Bicycle. 
# It’s natural to write code that creates MountainBike as a subclass 
# of Bicycle. This is the right structure, the class names are 
# correct, but the code in Bicycle is now very wrong.

# Subclasses are specializations of their superclasses. A 
# MountainBike should be everything a Bicycle is, plus more. Any 
# object that expects a Bicycle should be able to interact with a 
# MountainBike in blissful ignorance of its actual class.

# **
# These are the rules of inheritance; break them at your peril. 
# For inheritance to work, two things must always be true. 
#   * First, the objects that you are modeling must truly have a 
#     generalization–specialization relationship. 
#   * Second, you must use the correct coding techniques.

# It makes perfect sense to model mountain bike as a specialization 
# of bicycle; the relationship is correct. However, the code above is 
# a mess and if propagated will lead to disaster. The current Bicycle 
# class intermingles general bicycle code with specific road bike 
# code. It’s time to separate these two things, to move the road bike 
# code out of Bicycle and into a separate RoadBike subclass.

### Creating an Abstract Superclass ###

# Figure 6.6 shows a new class diagram where Bicycle is the 
# superclass of both MountainBike and RoadBike. This is your goal; 
# it’s the inheritance structure you intend to create. Bicycle will 
# contain the common behavior, and MountainBike and RoadBike will add 
# specializations. Bicycle’s public interface should include spares 
# and size, and the interfaces of its subclasses will add their 
# individual parts.

# Bicycle now represents an abstract class. Chapter 3, Managing 
# Dependencies, defined abstract as being disassociated from any 
# specific instance, and that definition still holds true. This new 
# version of Bicycle will not define a complete bike, just the bits 
# that all bicycles share. You can expect to create instances of 
# MountainBike and RoadBike, but Bicycle is not a class to which you 
# would ever send the new message. It wouldn’t make sense; Bicycle no 
# longer represents a whole bike.

# Some object-oriented programming languages have syntax that allows 
# you to explicitly declare classes as abstract. Java, for example, 
# has the abstract keyword. The Java compiler itself prevents 
# creation of instances of classes to which this keyword has been 
# applied. Ruby, in line with its trusting nature, contains no such 
# keyword and enforces no such restriction. Only good sense prevents 
# other programmers from creating instances of Bicycle; in real life, 
# this works remarkably well.

# **
# Abstract classes exist to be subclassed. This is their sole 
# purpose. They provide a common repository for behavior that is 
# shared across a set of subclasses—subclasses that in turn supply 
# specializations.

# It almost never makes sense to create an abstract superclass with 
# only one sub-class. Even though the original Bicycle class contains 
# general and specific behavior and it’s possible to imagine modeling 
# it as two classes from the very beginning, do not. Regardless of 
# how strongly you anticipate having other kinds of bikes, that day 
# may never come. Until you have a specific requirement that forces 
# you to deal with other bikes, the current Bicycle class is good 
# enough.

# Even though you now have a requirement for two kinds of bikes, this 
# still may not be the right moment to commit to inheritance. 
# Creating a hierarchy has costs; the best way to minimize these 
# costs is to maximize your chance of getting the abstraction right 
# before allowing subclasses to depend on it. While the two bikes you 
# know about supply a fair amount of information about the common 
# abstraction, three bikes would supply a great deal more. If you 
# could put this decision off until FastFeet asked for a third kind 
# of bike, your odds of finding the right abstraction would improve 
# dramatically.

# A decision to put off the creation of the Bicycle hierarchy commits 
# you to writing MountainBike and RoadBike classes that duplicate a 
# great deal of code. A decision to proceed with the hierarchy 
# accepts the risk that you may not yet have enough information to 
# identify the correct abstraction. Your choice about whether to wait 
# or to proceed RoadBike hinges on how soon you expect a third bike 
# to appear versus how much you expect the duplication to cost. If a 
# third bike is imminent, it may be best to duplicate the code and 
# wait for better information. However, if the duplicated code would 
# need to change every day, it may be cheaper to go ahead and create 
# the hierarchy. You should wait, if you can, but don’t fear to move 
# forward based on two concrete cases if this seems best.

############## Page 119 ##############
class Bicycle
  # This class is now empty.
  # All code has been moved to RoadBike.
end

class RoadBike < Bicycle
  # Now a subclass of Bicycle
  # Contains all code from the old Bicycle class.
end

class MountainBike < Bicycle
  # Still a subclass of Bicycle (whuch is now empty).
  # Code has not changed
end

# This code rearrangement merely moved the problem, as illustrated in 
# Figure 6.7. Now, instead of containing too much behavior, Bicycle 
# contains none at all. The common behavior needed by all bicycles is 
# stuck down inside of RoadBike and is therefore inaccessible to 
# MountainBike.

# This rearrangement improves your lot because it’s easier to promote 
# code up to a superclass than to demote it down to a subclass. The 
# reasons for this are not yet obvious but will become so as the 
# example proceeds.

road_bike = RoadBike.new(
  size:       'M',
  tape_color: 'red'
)

puts road_bike.size  # => "M"

mountain_bike = MountainBike.new(
      size:         'S',
      front_shock:  'Manitou',
      rear_shock:   'Fox')

puts mountain_bike.size
# NoMethodError: undefined method `size'

############## Page ?? ##############
# This is the complete code for example above
class Bicycle
  # This class is now empty.
  # All code has been moved to RoadBike.
end

class RoadBike < Bicycle
  attr_reader :size, :tape_color

  def initialize(args)
    @size       = args[:size]
    @tape_color = args[:tape_color]
  end

  def spares
    { chain:        '10-speed',
      tire_size:    '23',
      tape_color:   tape_color}
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock =  args[:rear_shock]
    super(args)
  end

  def spares
    super.merge({rear_shock:  rear_shock})
  end
end

road_bike = RoadBike.new(
              size:       'M',
              tape_color: 'red' )

puts road_bike.size  # => "M"

mountain_bike = MountainBike.new(
                  size:         'S',
                  front_shock:  'Manitou',
                  rear_shock:   'Fox')

puts mountain_bike.size
# NoMethodError: undefined method `size'

# It’s obvious why this error occurs; neither MountainBike nor any of 
# its superclasses implement size.


### Promoting Abstract Behavior ###

# The size and spares methods are common to all bicycles. This 
# behavior belongs in Bicycle’s public interface. Both methods are 
# currently stuck down in RoadBike; the task here is to move them up 
# to Bicycle so the behavior can be shared. Because the code dealing 
# with size is simplest it’s the most natural place to start.

############## Page 121 ##############
class Bicycle
  attr_reader :size         # <- promoted from RoadBike

  def initialize(args={})
    @size = args[:size]     # <- promoted from RoadBike
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)             # <- RoadBike now MUST send 'super'
  end
  # ...
end

# RoadBike now inherits the size method from Bicycle. When a RoadBike 
# receives size, Ruby itself delegates the message up the superclass 
# chain, searching for an implementation and finding the one in 
# Bicycle. This message delegation happens automatically because 
# RoadBike is a subclass of Bicycle.

############## Page 122 ##############
road_bike = RoadBike.new(
  size:       'M',
  tape_color: 'red' )

road_bike.size  # -> "M"

mountain_bike = MountainBike.new(
      size:         'S',
      front_shock:  'Manitou',
      rear_shock:   'Fox')

mountain_bike.size # -> 'S'

# **
# You might be tempted to skip the middleman and just leave this bit 
# of code in Bicycle to begin with, but this 
# push-everything-down-and-then-pull-some-things- up strategy is an 
# important part of this refactoring. Many of the difficulties of 
# inheritance are caused by a failure to rigorously separate the 
# concrete from the abstract. Bicycle’s original code intermingled 
# the two. If you begin this refactoring with that first version of 
# Bicycle, attempting to isolate the concrete code and push it down 
# to RoadBike, any failure on your part will leave dangerous remnants 
# of concreteness in the superclass. However, if you start by moving 
# every bit of the Bicycle code to RoadBike, you can then carefully 
# identify and promote the abstract parts without fear of leaving 
# concrete artifacts.

# When deciding between refactoring strategies, indeed, when deciding 
# between design strategies in general, it’s useful to ask the 
# question: “What will happen if I’m wrong?” In this case, if you 
# create an empty superclass and push the abstract bits of code up 
# into it, the worst that can happen is that you will fail to find 
# and promote the entire abstraction.

# This “promotion” failure creates a simple problem, one that is 
# easily found and easily fixed. When a bit of the abstraction gets 
# left behind, the oversight becomes visible as soon as another 
# subclass needs the same behavior. In order to give all subclasses 
# access to the behavior you’ll be forced to either duplicate the 
# code (in each subclass) or promote it (to the common superclass). 
# Because even the most junior programmers have been taught not to 
# duplicate code, this problem gets noticed no matter who works on 
# the application in the future. The natural course of events is such 
# that the abstraction gets identified and promoted, and the code 
# improves. Promotion failures thus have low consequences.


# **
# The general rule for refactoring into a new inheritance hierarchy 
# is to arrange code so that you can promote abstractions rather than 
# demote concretions.

### Separating Abstract from Concrete ###

############## Page ??? ##############
class MountainBike < Bicycle
  # ...
  def spares
    super.merge({rear_shock:  rear_shock})
  end
end

############## Page ??? ##############
mountain_bike.spares
# NoMethodError: super: no superclass method `spares'

# Fixing this problem obviously requires adding a spares method to 
# Bicycle, but doing so is not as simple as promoting the existing 
# code from RoadBike.

# RoadBike’s spares implementation knows far too much. The chain and 
# tire_size attributes are common to all bicycles, but tape_color 
# should be known only to road bikes. The hard-coded chain and 
# tire_size values are not the correct defaults for every possible 
# subclass. This method has many problems and cannot be promoted as 
# is.

# It mixes a bunch of different things. When this awkward mix was 
# hidden inside a single method of a single class it was survivable, 
# even (depending on your tolerance) ignorable, but now that you 
# would like to share only part of this behavior, you must untangle 
# the mess and separate the abstract parts from the concrete parts. 
# The abstractions will be promoted up to Bicycle, the concrete parts 
# will remain in RoadBike.

# Here are the requirements for promoting bicycle share, chain and 
# tire_size:
# • Bicycles have a chain and a tire size.
# • All bicycles share the same default for chain.
# • Subclasses provide their own default for tire size.
# • Concrete instances of subclasses are permitted to ignore defaults 
#   and supply instance-specific values.

############## Page 125 ##############
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size       = args[:size]
    @chain      = args[:chain]
    @tire_size  = args[:tire_size]
  end
  # ...
end

# RoadBike and MountainBike inherit the attr_reader definitions in 
# Bicycle and both send super in their initialize methods. All bikes 
# now understand size, chain, and tire_size and each may supply 
# subclass-specific values for these attributes. The first and last 
# requirements listed above have been met.

### Using the Template Method Pattern ###

# This next change alters Bicycle’s initialize method to send 
# messages to get defaults. 

# While wrapping the defaults in methods is good practice in general, 
# these new message sends serve a dual purpose. Bicycle’s main goal 
# in sending these messages is to give subclasses an opportunity to 
# contribute specializations by overriding them.

# **
# This technique of defining a basic structure in the superclass and 
# sending messages to acquire subclass-specific contributions is 
# known as the template method pattern.

# In the following code, MountainBike and RoadBike take advantage of 
# only one of these opportunities for specialization. Both implement 
# default_tire_size, but neither implements default_chain. Each 
# subclass thus supplies its own default for tire size but inherits 
# the common default for chain.

############## Page 126 ##############
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size       = args[:size]
    @chain      = args[:chain]      || default_chain
    @tire_size  = args[:tire_size]  || default_tire_size
  end

  def default_chain       # <- common default
    '10-speed'
  end
end

class RoadBike <  Bicycle
  # ...
  def default_tire_size   # <- subclass default
    '23'
  end
end

class MountainBike < Bicycle
  # ...
  def default_tire_size   # <- subclass default
    '2.1'
  end
end

# Bicycle now provides structure, a common algorithm if you will, for 
# its subclasses. Where it permits them to influence the algorithm, 
# it sends messages. Subclasses contribute to the algorithm by 
# implementing matching methods.

# All bicycles now share the same default for chain but use different 
# defaults for tire size

############## Page 126 ##############
road_bike = RoadBike.new(
  size:       'M',
  tape_color: 'red' )

puts road_bike.tire_size     # => '23'
puts road_bike.chain         # => "10-speed"

mountain_bike = MountainBike.new(
      size:         'S',
      front_shock:  'Manitou',
      rear_shock:   'Fox')

puts mountain_bike.tire_size # => '2.1'
puts road_bike.chain         # => "10-speed"

# **
# It’s too early to celebrate this success, however, because there’s 
# still something wrong with the code. It contains a booby trap, 
# awaiting the unwary.

### Implementing Every Template Method ###

# Bicycle’s initialize method sends default_tire_size but Bicycle 
# itself does not implement it. This omission can cause problems 
# downstream. Imagine that FastFeed adds another new bicycle type, 
# the recumbent. Recumbents are low, long bicycles that place the 
# rider in a laid-back, reclining position; these bikes are fast and 
# easy on the rider’s back and neck.

# What happens if some programmer innocently creates a new 
# RecumbentBike subclass but neglects to supply a default_tire_size 
# implementation?

############## Page 127 ##############
class RecumbentBike < Bicycle
  def default_chain
    '9-speed'
  end
end

bent = RecumbentBike.new
# NameError: undefined local variable or method
#   `default_tire_size'

############## Page ??? ##############
  # This line of code is a time bomb
  @tire_size  = args[:tire_size]  || default_tire_size

# The original designer of the hierarchy rarely encounters this 
# problem. She wrote Bicycle; she understands the requirements that 
# subclasses must meet. The existing code works. These errors occur 
# in the future, when the application is being changed to meet a new 
# requirement, and are encountered by other programmers, ones who 
# understand far less about what’s going on.

# The root of the problem is that Bicycle imposes a requirement upon 
# its subclasses that is not obvious from a glance at the code. As 
# Bicycle is written, subclasses must implement default_tire_size. 
# Innocent and well-meaning subclasses like RecumbentBike may fail 
# because they do not fulfill requirements of which they are unaware.

# **
# A world of potential hurt can be assuaged, in advance, by following 
# one simple rule. Any class that uses the template method pattern 
# must supply an implementation for every message it sends,


############## Page 128 ##############
class Bicycle
  # ...
  def default_tire_size
    raise NotImplementedError
  end
end

# Explicitly stating that subclasses are required to implement a 
# message provides useful documentation for those who can be relied 
# upon to read it and useful error messages for those who cannot.

############## Page 128 ##############
bent = RecumbentBike.new
#  NotImplementedError: NotImplementedError

############## Page 128 ##############
class Bicycle
  # ...
  def default_tire_size
    raise NotImplementedError,
          "This #{self.class} cannot respond to:"
  end
end

############## Page 129 ##############
bent = RecumbentBike.new
#  NotImplementedError:
#    This RecumbentBike cannot respond to:
#	     `default_tire_size'

# **
# Creating code that fails with reasonable error messages takes minor 
# effort in the present but provides value forever. Each error 
# message is a small thing, but small things accumulate to produce 
# big effects and it is this attention to detail that marks you as a 
# serious programmer. Always document template method requirements by 
# implementing matching methods that raise useful errors.
