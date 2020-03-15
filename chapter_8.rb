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