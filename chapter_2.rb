############## Page 18 ##############
chainring = 52                    # number of teeth
cog       = 11
ratio     = chainring / cog.to_f
puts ratio                        # -> 4.72727272727273

chainring = 30
cog       = 27
ratio     = chainring / cog.to_f
puts ratio                        # -> 1.11111111111111

############## Page 19 ##############
class Gear
  attr_reader :chainring, :cog
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    chainring / cog.to_f
  end
end

puts Gear.new(52, 11).ratio       # -> 4.72727272727273
puts Gear.new(30, 27).ratio       # -> 1.11111111111111

############## Page 20 ##############
class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @rim       = rim
    @tire      = tire
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    # wheel diameter * gear ratio
    # wheel diameter = rim + twice tire diameter
    # tire goes around rim twice for diameter
    ratio * (rim + (tire * 2))
  end
end

puts Gear.new(52, 11, 26, 1.5).gear_inches
# -> 137.0909090909091

puts Gear.new(52, 11, 24, 1.25).gear_inches
# -> 125.27272727272728

############## Page 20 ##############
puts Gear.new(52, 11).ratio # didn't this used to work?
# chapter_2.rb:31:in `initialize': wrong number of arguments (given 2, expected 4) (ArgumentError)
#    from chapter_2.rb:57:in `new'
#    from chapter_2.rb:57:in `<main>'

############## Page 24 ##############
class Gear:
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    @chainring / @cog.to_f        # <-- road to ruin
  end
end

############## Page 25 ##############
class Gear
  attr_reader :chainring, :cog # <------
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    chainring / cog.to_f       # <------
  end
end

############## Page 25 ##############
# default implementation via attr_read
def cog
  @cog
end

############## Page 25 ##############
# a simple reimplementation of cog
def cog
  @cog * unanticipated_adjustment_factor
end

############## Page 25 ##############
# a more comle one
def cog
  @cog * (foo? ? bar_adjustment : baz_adjustment)
end