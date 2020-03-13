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