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