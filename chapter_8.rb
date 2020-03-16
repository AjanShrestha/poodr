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
road_bike_parts = Parts.new([chain, road_tire, tape])

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