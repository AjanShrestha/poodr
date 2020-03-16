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

### Updating the Bicycle Class ###

# The Bicycle class is currently an abstract superclass in an 
# inheritance hierarchy and you’d like to convert it to use 
# composition. The first step is to ignore the existing code and 
# think about how a bicycle should be composed.

# The Bicycle class is responsible for responding to the spares 
# message. This spares message should return a list of spare parts. 
# Bicycles have parts, the bicycle–parts relationship quite naturally 
# feels like composition. If you created an object to hold all of a 
# bicycle’s parts, you could delegate the spares message to that new 
# object.

# It’s reasonable to name this new class Parts. The Parts object can 
# be responsible for holding a list of the bike’s parts and for 
# knowing which of those parts needs spares. Notice that this object 
# represents a collection of parts, not a single part.

# The sequence diagram in Figure 8.1 illustrates this idea. Here, a 
# Bicycle sends the spares message to its Parts object.

# Every Bicycle needs a Parts object; part of what it means to be a 
# Bicycle is to have-a Parts. The class diagram in Figure 8.2 
# illustrates this relationship.

# This diagram shows the Bicycle and Parts classes connected by a 
# line. The line attaches to Bicycle with a black diamond; this black 
# diamond indicates composition, it means that a Bicycle is composed 
# of Parts. The Parts side of the line has the number “1.” This means 
# there’s just one Parts object per Bicycle.

############## Page 165 ##############
class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size         = args[:size]
    @parts        = args[:parts]
  end

  def spares
    parts.spares
  end
end

# Bicycle is now responsible for three things: knowing its size, 
# holding onto its Parts, and answering its spares.

### Creating a Parts Hierarchy ###

# That was easy, but only because there wasn’t much bicycle related 
# behavior in the Bicycle class to begin with; most of the code in 
# Bicycle dealt with parts. You still need the parts behavior that 
# you just removed from Bicycle, and the simplest way to get this 
# code working again is to simply fling that code into a new 
# hierarchy of Parts, as shown below.

############## Page 165 ##############
class Parts
  attr_reader :chain, :tire_size

  def initialize(args={})
    @chain          = args[:chain]      || default_chain
    @tire_size      = args[:tire_size]  || default_tire_size
    post_initialize(args)
  end

  def spares
    {
      tire_size: tire_size,
      chain: chain
    }.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  # subclasses may override
  def post_initialize(args)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
    '10-speed'
  end
end

class RoadBikeParts < Parts
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    {tape_color: tape_color}
  end

  def default_tire_size
    '23'
  end
end

class MountainBikeParts < Parts
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock  = args[:front_shock]
    @rear_shock   = args[:rear_shock]
  end

  def local_spares
    {rear_shock: rear_shock}
  end

  def default_tire_size
    '2.1'
  end
end

# This code is a near exact copy of the Bicycle hierarchy from 
# Chapter 6; the differences are that the classes have been renamed 
# and the size variable has been removed.

# The class diagram in Figure 8.3 illustrates this transition. There 
# is now an abstract Parts class. Bicycle is composed of Parts. Parts 
# has two subclasses, RoadBikeParts and MountainBikeParts.

# After this refactoring, everything still works. As you can see 
# below, regardless of whether it has RoadBikeParts or 
# MountainBikeParts, a bicycle can still correctly answer its size 
# and spares.

############## Page 167 ##############
road_bike =
  Bicycle.new(
    size:  'L',
    parts: RoadBikeParts.new(tape_color: 'red'))

puts road_bike.size    # -> 'L'

puts road_bike.spares
# -> {:tire_size=>"23",
#     :chain=>"10-speed",
#     :tape_color=>"red"}

mountain_bike =
  Bicycle.new(
    size:  'L',
    parts: MountainBikeParts.new(rear_shock: 'Fox'))

puts mountain_bike.size   # -> 'L'

puts mountain_bike.spares
# -> {:tire_size=>"2.1",
#     :chain=>"10-speed",
#     :rear_shock=>"Fox"}

# **
# This wasn’t a big change and it isn’t much of an improvement. 
# However, this refactoring did reveal one useful thing; it made it 
# blindingly obvious just how little Bicycle specific code there was 
# to begin with. Most of the code above deals with individual parts; 
# the Parts hierarchy now cries out for another refactoring.

## Composing the Parts Object ##

# By definition a parts list contains a list of individual parts. 
# It’s time to add a class to represent a single part. The class name 
# for an individual part clearly ought to be Part but introducing a 
# Part class when you already have a Parts class makes conversation a 
# challenge. It is confusing to use the word “parts” to refer to a 
# collection of Part objects, when that same word already refers to a 
# single Parts object. However, the previous phrase illustrates a 
# technique that side steps the communication problem; when 
# discussing Part and Parts, you can follow the class name with the 
# word “object” and pluralize “object” as necessary.

# You can also avoid the communication problem from the beginning by 
# choosing different class names, but other names might not be as 
# expressive and may well introduce communication problems of their 
# own. This Parts/Part situation is common enough that it’s worth 
# dealing with head-on. Choosing these class names requires a 
# precision of communication that’s a worthy goal in itself.

# Thus, there’s a Parts object, and it may contain many Part 
# objects—simple as that.

### Creating a Part ###

# Figure 8.4 shows a new sequence diagram that illustrates the 
# conversation between Bicycle and its Parts object, and between a 
# Parts object and its Part objects. Bicycle sends spares to Parts 
# and then the Parts object sends needs_spare to each Part.

# Changing the design in this way requires creating a new Part 
# object. The Parts object is now composed of Part objects, as 
# illustrated by the class diagram in Figure 8.5. The “1..*” on the 
# line near Part indicates that a Parts will have one or more Part 
# objects.

# Introducing this new Part class simplifies the existing Parts 
# class, which now becomes a simple wrapper around an array of Part 
# objects. Parts can filter its list of Part objects and return the 
# ones that need spares. The code below shows three classes: the 
# existing Bicycle class, the updated Parts class, and the newly 
# introduced Part class.

############## Page 169 ##############
class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size       = args[:size]
    @parts      = args[:parts]
  end

  def spares
    parts.spares
  end
end

class Parts
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def spares
    parts.select {|part| part.needs_spare}
  end
end

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name         = args[:name]
    @description  = args[:description]
    @needs_spare  = args.fetch(:needs_spare, true)
  end
end

# Now that these three classes exist you can create individual Part 
# objects. The following code creates a number of different parts and 
# saves each in an instance variable.

############## Page 170 ##############
chain = Part.new(name: 'chain', description: '10-speed')

road_tire = Part.new(name: 'tire_size', description: '23')

tape = Part.new(name: 'tape_color', description: 'red')

mountain_tire = Part.new(name: 'tire_size', description: '2.1')

rear_shock = Part.new(name: 'rear_shock', description: 'Fox')

front_shock = Part.new(
  name: 'front_shock', 
  description: 'Manitou', 
  needs_spare: false
)

# Individual Part objects can be grouped together into a Parts. The 
# code below combines the road bike Part objects into a road bike 
# suitable Parts.

############## Page 171 ##############
# road_bike_parts = Parts.new([chain, road_tire, tape])

# Of course, you can skip this intermediate step and simply construct 
# the Parts object on the fly when creating a Bicycle,

############## Page 171 ##############
road_bike =
  Bicycle.new(
    size:  'L',
    parts: Parts.new([chain,
                      road_tire,
                      tape]))

puts road_bike.size    # -> 'L'

puts road_bike.spares
# -> [#<Part:0x00000101036770
#         @name="chain",
#         @description="10-speed",
#         @needs_spare=true>,
#     #<Part:0x0000010102dc60
#         @name="tire_size",
#         etc ...

mountain_bike =
  Bicycle.new(
    size:  'L',
    parts: Parts.new([chain,
                      mountain_tire,
                      front_shock,
                      rear_shock]))

puts mountain_bike.size    # -> 'L'

puts mountain_bike.spares
# -> [#<Part:0x00000101036770
#         @name="chain",
#         @description="10-speed",
#         @needs_spare=true>,
#     #<Part:0x0000010101b678
#         @name="tire_size",
#         etc ...

# **
# This new code arrangement works just fine, and it behaves almost 
# exactly like the old Bicycle hierarchy. There is one difference: 
# Bicycle’s old spares method returned a hash, but this new spares 
# method returns an array of Part objects.
# While it may be tempting to think of these objects as instances of 
# Part, composition tells you to think of them as objects that play 
# the Part role. They don’t have to be a kind-of the Part class, they 
# just have to act like one; that is, they must respond to name, 
# description, and needs_spare.

# **
### Making the Parts Object More Like an Array ###

# This code works but there’s definitely room for improvement. Step 
# back for a minute and think about the parts and spares methods of 
# Bicycle. These messages feel like they ought to return the same 
# sort of thing, yet the objects that come back don’t behave in the 
# same way. Look at what happens when you ask each for its size.

############## Page 172 ##############
puts mountain_bike.spares.size # -> 3
# puts mountain_bike.parts.size
# -> NoMethodError:
#      undefined method `size' for #<Parts:...>

# Failures like this will chase you around for as long as you own 
# this code. These two things both seem like arrays. You will 
# inevitably treat them as if they are, despite the fact that exactly 
# one half of the time, the result will be like stepping on the 
# proverbial rake in the yard. The Parts object does not behave like 
# an array and all attempts to treat it as one will fail.

# You can fix the proximate problem by adding a size method to Parts. 
# This is a simple matter of implementing a method to delegate size 
# to the actual array, as shown here:

############## Page 173 ##############
def size
  parts.size
end

# However, this change starts the Parts class down a slippery slope. 
# Do this, and it won’t be long before you’ll want Parts to respond 
# to each, and then sort, and then everything else in Array. This 
# never ends; the more array-like you make Parts, the more like an 
# array you’ll expect it to be.
# Perhaps Parts is an Array, albeit one with a bit of extra behavior. 
# You could make it one; the next example shows a new version of the 
# Parts class, now as a subclass of Array.

############## Page 173 ##############
# class Parts < Array
#   def spares
#     select {|part| part.needs_spare}
#   end
# end

# The above code is a very straightforward expression of the idea 
# that Parts is a specialization of Array; in a perfect 
# object-oriented language this solution would be exactly correct. 
# Unfortunately, the Ruby language has not quite achieved perfection 
# and this design contains a hidden flaw.

# This next example illustrates the problem. When Parts subclasses 
# Array, it inherits all of Array’s behavior. This behavior includes 
# methods like +, which adds two arrays together and returns a third. 
# Lines 3 and 4 below show + combining two existing instances of 
# Parts and saving the result into the combo_parts variable.

# This appears to work; combo_parts now contains the correct number 
# of parts (line 7). However, something is clearly not right. As line 
# 12 shows, combo_parts cannot answer its spares.

# The root cause of the problem is revealed by lines 15–17. Although 
# the objects that got +’d together were instances of Parts, the 
# object that + returned was an instance of Array, and Array does not 
# understand spares.

############## Page 174 ##############
#  Parts inherits '+' from Array, so you can
#    add two Parts together.
# combo_parts =
#   (mountain_bike.parts + road_bike.parts)

# # '+' definitely combines the Parts
# puts combo_parts.size            # -> 7

# # but the object that '+' returns
# #   does not understand 'spares'
# puts combo_parts.spares
# # -> NoMethodError: undefined method `spares'
# #      for #<Array:...>

# puts mountain_bike.parts.class   # -> Parts
# puts road_bike.parts.class       # -> Parts
# puts combo_parts.class           # -> Array !!!

# **
# It turns out that there are many methods in Array that return new 
# arrays, and unfortunately these methods return new instances of the 
# Array class, not new instances of your subclass. The Parts class is 
# still misleading and you have just swapped one problem for another. 
# Where once you were disappointed to find that Parts did not 
# implement size, now you might be surprised to find that adding two 
# Parts together returns a result that does not understand spares.
# You’ve seen three different implementations of Parts. The first 
# answers only the spares and parts messages; it does not act like an 
# array, it merely contains one. The second Parts implementation adds 
# size, a minor improvement that just returns the size of its 
# internal array. The most recent Parts implementation subclasses 
# Array and therefore gives the appearance of fully behaving like an 
# array, but as the example above shows, an instance of Parts still 
# displays unexpected behavior.
# It has become clear that there is no perfect solution; it’s 
# therefore time to make a difficult decision. Even though it cannot 
# respond to size, the original Parts implementation may be good 
# enough; if so, you can accept its lack of array-like behavior and 
# revert to that version. If you need size and size alone, it may be 
# best to add just this one method and so settle for the second 
# implementation. If you can tolerate the possibility of confusing 
# errors or you know with absolute certainty that you’ll never 
# encounter them, it might make sense to subclass Array and walk 
# quietly away.

# Somewhere in the middle ground between complexity and usability 
# lies the following solution. The Parts class below delegates size 
# and each to its @parts array and includes Enumerable to get common 
# traversal and searching methods. This version of Parts does not 
# have all of the behavior of Array, but at least everything that it 
# claims to do actually works.

############## Page 175 ##############
require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select {|part| part.needs_spare}
  end
end

############## Page ?? ##############
# Full listing for above
class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size       = args[:size]
    @parts      = args[:parts]
  end

  def spares
    parts.spares
  end
end

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select {|part| part.needs_spare}
  end
end

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name         = args[:name]
    @description  = args[:description]
    @needs_spare  = args.fetch(:needs_spare, true)
  end
end

#this duplicates #012
chain =
  Part.new(name: 'chain', description: '10-speed')

road_tire =
  Part.new(name: 'tire_size',  description: '23')

tape =
  Part.new(name: 'tape_color', description: 'red')

mountain_tire =
  Part.new(name: 'tire_size',  description: '2.1')

rear_shock =
  Part.new(name: 'rear_shock', description: 'Fox')

front_shock =
  Part.new(
    name: 'front_shock',
    description: 'Manitou',
    needs_spare: false)

# Sending + to an instance of this Parts results in a NoMethodError 
# exception. However, because Parts now responds to size, each, and 
# all of Enumerable, and obligingly raises errors when you mistakenly 
# treat it like an actual Array, this code may be good enough. The 
# following example shows that spares and parts can now both respond 
# to size.

############## Page 175 ##############
mountain_bike =
  Bicycle.new(
    size:  'L',
    parts: Parts.new([chain,
                      mountain_tire,
                      front_shock,
                      rear_shock]))

puts mountain_bike.spares.size   # -> 3
puts mountain_bike.parts.size    # -> 4

############## Page ??? ##############
# mountain_bike.parts + road_bike.parts
# -> NoMethodError: undefined method `+'
#      for #<Parts:....>

## Manufacturing Parts ##

# Look back at lines 4–7 above. The Part objects held in the chain, 
# mountain_tire, and so on, variables were created so long ago that 
# you may already have forgotten them. Think about the body of 
# knowledge that these four lines represent. Somewhere in your 
# application, some object had to know how to create these Part 
# objects. And here, on lines 4–7 above, this place has to know that 
# these four specific objects go with mountain bikes.

# This is a lot of knowledge and it can easily leak all over your 
# application. This leakage is both unfortunate and unnecessary. 
# Although there are lots of different individual parts, there are 
# only a few valid combinations of parts. Everything would be easier 
# if you could describe the different bikes and then use your 
# descriptions to magically manufacture the correct Parts object for 
# any bike.

# It’s easy to describe the combination of parts that make up a 
# specific bike. The code below does this with a simple 2-dimensional 
# array, where each row contains three possible columns. The first 
# column contains the part name ('chain', 'tire_size', etc.), the 
# second, the part description ('10-speed', '23', etc.) and the third 
# (which is optional), a Boolean that indicates whether this part 
# needs a spare. Only 'front_shock' on line 9 below puts a value in 
# this third column, the other parts would like to default to true, 
# as they require spares.

############## Page 176 ##############
road_config = [
  ['chain',        '10-speed'],
  ['tire_size',    '23'],
  ['tape_color',   'red']
]

mountain_config = [
  ['chain',        '10-speed'],
  ['tire_size',    '2.1'],
  ['front_shock',  'Manitou', false],
  ['rear_shock',   'Fox']
]

# Unlike a hash, this simple 2-dimensional array provides no 
# structural information. However, you understand how this structure 
# is organized and you can encode your knowledge into a new object 
# that manufactures Parts.

### Creating the PartsFactory ###

# As discussed in Chapter 3, Managing Dependencies, an object that 
# manufactures other objects is a factory. Your past experience in 
# other languages may predispose you to flinch when you hear this 
# word, but think of this as an opportunity to reclaim it. The word 
# factory does not mean difficult, or contrived, or overly 
# complicated; it’s merely the word OO designers use to concisely 
# communicate the idea of an object that creates other objects. Ruby 
# factories are simple and there’s no reason to avoid this intention 
# revealing word.

# The code below shows a new PartsFactory module. Its job is to take 
# an array like one of those listed above and manufacture a Parts 
# object. Along the way it may well create Part objects, but this 
# action is private. Its public responsibility is to create a Parts.

# This first version of PartsFactory takes three arguments, a config, 
# and the names of the classes to be used for Part, and Parts. Line 6 
# below creates the new instance of Parts, initializing it with an 
# array of Part objects built from the information in the config.

############## Page 177 ##############
module PartsFactory
  def self.build(config,
                  part_class  = Part,
                  parts_class = Parts)
    parts_class.new(
      config.collect {|part_config|
        part_class.new(
          name:           part_config[0],
          description:    part_config[1],
          needs_spare:    part_config.fetch(2, true)
        )
      }
    )
  end
end

# This factory knows the structure of the config array. It expects 
# name to be in the first column, description to be in the second, 
# and needs_spare to be in the third.

# **
# Putting knowledge of config’s structure in the factory has two 
# consequences. First, the config can be expressed very tersely. 
# Because PartsFactory understands config’s internal structure, 
# config can be specified as an array rather than a hash. Second, 
# once you commit to keeping config in an array, you should always 
# create new Parts objects using the factory. To create new Parts via 
# any other mechanism requires duplicating the knowledge

# Now that PartsFactory exists, you can use the configuration arrays 
# defined above to easily create new Parts, as shown here:

############## Page 178 ##############
road_parts = PartsFactory.build(road_config)
# -> [#<Part:0x00000101825b70
#       @name="chain",
#       @description="10-speed",
#       @needs_spare=true>,
#     #<Part:0x00000101825b20
#       @name="tire_size",
#          etc ...

mountain_parts = PartsFactory.build(mountain_config)
# -> [#<Part:0x0000010181ea28
#        @name="chain",
#        @description="10-speed",
#        @needs_spare=true>,
#     #<Part:0x0000010181e9d8
#        @name="tire_size",
#        etc ...

# **
# PartsFactory, combined with the new configuration arrays, isolates 
# all the knowledge needed to create a valid Parts. This 
# information was previously dispersed throughout the application but 
# now it is contained in this one class and these two arrays.

### Leveraging the PartsFactory ###

# Now that the PartsFactory is up and running, have another look at 
# the Part class (repeated below). Part is simple. Not only that, the 
# only even slightly complicated line of code (the fetch on line 7 
# below) is duplicated in PartsFactory. If PartsFactory created every 
# Part, Part wouldn’t need this code. And if you remove this code 
# from Part, there’s almost nothing left; you can replace the whole 
# Part class with a simple OpenStruct.

############## Page 179 ##############
class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name         = args[:name]
    @description  = args[:description]
    @needs_spare  = args.fetch(:needs_spare, true)
  end
end

# **
# Ruby’s OpenStruct class is a lot like the Struct class that you’ve 
# already seen, it provides a convenient way to bundle a number of 
# attributes into an object. The difference between the two is that 
# Struct takes position order initialization arguments while 
# OpenStruct takes a hash for its initialization and then derives 
# attributes from the hash.
# There are good reasons to remove the Part class; this simplifies 
# the code and you may never again need anything as complicated as 
# what you currently have. You can remove all trace of Part by 
# deleting the class and then changing PartsFactory to use OpenStruct 
# to create an object that plays the Part role. The following code 
# shows a new version of PartFactory where part creation has been 
# refactored into a method of its own.

############## Page 179 ##############
require 'ostruct'
module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect {|part_config|
        create_part(part_config)
      }
    )
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name:         part_config[0],
      description:  part_config[1],
      needs_spare:  part_config.fetch(2, true)
    )
  end
end

# This new version of PartsFactory works. As shown below, it returns 
# a Parts that contains an array of OpenStruct objects, each of which 
# plays the Part role.

############## Page 180 ##############
mountain_parts = PartsFactory.build(mountain_config)
# -> <Parts:0x000001009ad8b8 @parts=
#      [#<OpenStruct name="chain",
#                    description="10-speed",
#                    needs_spare=true>,
#       #<OpenStruct name="tire_size",
#                    description="2.1",
#                    etc ...

## The Composed Bicycle ##

# The following code shows that Bicycle now uses composition. It 
# shows Bicycle, Parts, and PartsFactory and the configuration arrays 
# for road and mountain bikes. Bicycle has-a Parts, which in turn 
# has-a collection of Part objects. Parts and

# Part may exist as classes, but the objects in which they are 
# contained think of them as roles. Parts is a class that plays the 
# Parts role; it implements spares. The role of Part is played by an 
# OpenStruct, which implements name, description and needs_spare.

# The following 54 lines of code completely replace the 66-line 
# inheritance hierarchy from Chapter 6.

class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size       = args[:size]
    @parts      = args[:parts]
  end

  def spares
    parts.spares
  end
end

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select {|part| part.needs_spare}
  end
end

require 'ostruct'
module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect {|part_config|
        create_part(part_config)})
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name:        part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true))
  end
end

road_config = [
  ['chain',        '10-speed'],
  ['tire_size',    '23'],
  ['tape_color',   'red']
]

mountain_config = [
  ['chain',        '10-speed'],
  ['tire_size',    '2.1'],
  ['front_shock',  'Manitou', false],
  ['rear_shock',   'Fox']
]

# This new code works much like the prior Bicycle hierarchy. The only 
# difference is that the spares message now returns an array of 
# Part-like objects instead of a hash

############## Page 182 ##############
road_bike =
  Bicycle.new(
    size: 'L',
    parts: PartsFactory.build(road_config))

puts road_bike.spares
# -> [#<OpenStruct name="chain", etc ...

mountain_bike =
  Bicycle.new(
    size: 'L',
    parts: PartsFactory.build(mountain_config))

puts mountain_bike.spares
# -> [#<OpenStruct name="chain", etc ...
#

# Now that these new classes exist, it’s very easy to create a new 
# kind of bike. Adding support for recumbent bikes took 19 new lines 
# of code in Chapter 6. This task can now be accomplished with 3 
# lines of configuration.

############## Page 182 ##############
recumbent_config = [
  ['chain',        '9-speed'],
  ['tire_size',    '28'],
  ['flag',         'tall and orange']
]

recumbent_bike =
  Bicycle.new(
    size: 'L',
    parts: PartsFactory.build(recumbent_config))

puts recumbent_bike.spares
# -> [#<OpenStruct
#       name="chain",
#       description="9-speed",
#       needs_spare=true>,
#     #<OpenStruct
#       name="tire_size",
#       description="28",
#       needs_spare=true>,
#     #<OpenStruct
#       name="flag",
#       description="tall and orange",
#       needs_spare=true>]

# ***
# ------------------------------------------------------
#Aggregation: A Special Kind of Composition

# You already know the term delegation; delegation is when one object 
# receives a message and merely forwards it to another. Delegation 
# creates dependencies; the receiving object must recognize the 
# message and know where to send it.

# Composition often involves delegation but the term means something 
# more. A composed object is made up of parts with which it expects 
# to interact via well-defined interfaces.

# Composition describes a has-a relationship. Meals have appetizers, 
# universities have departments, bicycles have parts. Meals, 
# universities, and bicycles are composed objects. Appetizers, 
# departments, and parts are roles. The composed object depends on 
# the interface of the role.
# Because meals interact with appetizers using an interface, new 
# objects that wish to act as appetizers need only implement this 
# interface. Unanticipated appetizers fit seamlessly and 
# interchangeably into existing meals.

# The term composition can be a bit confusing because it gets used 
# for two slightly different concepts. The definition above is for 
# the broadest use of the term. In most cases when you see 
# composition it will indicate nothing more than this general has-a 
# relationship between two objects.
# However, as formally defined it means something a bit more 
# specific; it indicates a has-a relationship where the contained 
# object has no life independent of its container. When used in this 
# stricter sense you know not only that meals have appetizers, but 
# also that once the meal is eaten the appetizer is also gone.

# This leaves a gap in the definition that is filled by the term 
# aggregation. Aggregation is exactly like composition except that 
# the contained object has an independent life. Universities have 
# departments, which in turn have professors. If your application 
# manages many universities and knows about thousands of professors, 
# it’s quite reasonable to expect that although a department 
# completely disappears when its university goes defunct, its 
# professors continue to exist.

# The university–department relationship is one of composition (in 
# its strictest sense) and the department–professor relationship is 
# aggregation.
# Destroying a department does not destroy its professors; they have 
# an existence and life of their own.

# This distinction between composition and aggregation may have 
# little practical effect on your code. Now that you are familiar 
# with both terms you can use composition to refer to both kinds of 
# relationships and be more explicit only if the need arises.
# ------------------------------------------------------

# **
## Deciding Between Inheritance and Composition ##

# Remember that classical inheritance is a code arrangement 
# technique. Behavior is dispersed among objects and these objects 
# are organized into class relationships such that automatic 
# delegation of messages invokes the correct behavior. Think of it 
# this way: For the cost of arranging objects in a hierarchy, you get 
# message delegation for free.

# Composition is an alternative that reverses these costs and 
# benefits. In composition, the relationship between objects is not 
# codified in the class hierarchy; instead objects stand alone and as 
# a result must explicitly know about and delegate messages to one 
# another. Composition allows objects to have structural 
# independence, but at the cost of explicit message delegation.

# Now that you’ve seen examples of inheritance and composition you 
# can begin to think about when to use them. The general rule is 
# that, faced with a problem that composition can solve, you should 
# be biased towards doing so. If you cannot explicitly defend 
# inheritance as a better solution, use composition. Composition 
# contains far fewer built-in dependencies than inheritance; it is 
# very often the best choice.

# Inheritance is a better solution when its use provides high rewards 
# for low risk
