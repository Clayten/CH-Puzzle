# playtime challenge based off of XKCD wiki Magic Watch brain teaser

class Watch
  class ImproperQuestion       < RuntimeError ; end
  class EncapsulationViolation < RuntimeError ; end
  def self.encapsulation_signature ; /\`ask'/ ; end
  def self.encapsulation_levels    ; caller.select {|c| c =~ encapsulation_signature }.length ; end
  def self.encapsulation_check     ; raise EncapsulationViolation, "You can't look directly" if encapsulation_levels.zero? ; end
  def      encapsulation_check     ; self.class.encapsulation_check ; end
    
  def initialize options = {}
    @t, @f = [:blue, :yellow].shuffle
    @free_recursion = !!options[:free_recursion]
    @questions      =   options[:num_guesses] || 2
  end
  def ask *a
    return if @questions.zero?
    nesting_level = caller.select {|c| c =~ /\`ask'/ }.length
    deducted = @questions -= 1 if nesting_level.zero? || !@free_recursion # the first question always costs, recursive questions may not cost further
    answer = yield *a
    raise ImproperQuestion, "Only true/false questions" unless [true, false].include? answer
    answer ? @t : @f
  rescue
    @questions += 1 if deducted # failed questions don't count, but only refund if we charged
    raise
  end
  def questions
    @questions
  end
  def truth_color
    @t unless encapsulation_check # not really a conditional...
  end
  def inspect
    "<#{self.class.name}:#{object_id} @questions=#{@questions}, @free_recursion=#{@free_recursion}>"
  end
end

class DoorGuesser
  def self.encapsulator ; Watch ; end
  attr_accessor :encapsulator

  def self.play options = {}, &b
    game   = options.delete :game
    oracle = options.delete :oracle
    game   ||= new(options)
    oracle ||= encapsulator.new(options)
    return [game, oracle] unless b
    door = game.instance_exec game, oracle, &b
    game.guess door
  end

  # define a method from a block (remains a closure) on the game instance, for writing easier queries in game mode
  # DoorGuesser.new {|g,w|
  #   prop :door_one_has_a_goat do room1 == :goat end
  #   first_answer = w.ask { door_one_has_a_goat }
  #   ...
  def prop name, &b
    define_singleton_method name, &b
  end

  class SequenceViolation < RuntimeError ; end
  def enforce_no_peeking   ; raise SequenceViolation, "can't peek until you guess" unless @guessed ; end
  def enforce_single_guess ; raise SequenceViolation, "can't guess more than once" if     @guessed ; end
  def encapsulation_check  ; encapsulator.encapsulation_check ; end

  def initialize options = {}
    @encapsulator = options.delete(:encapsulator) || self.class.encapsulator

    size = options.delete(:size) || 3
    @rooms = [:goat] * size
    @rooms[rand size] = :car
    @guessed = false
  end
  def peek
    enforce_no_peeking
    @rooms
  end
  def guess n
    enforce_single_guess
    raise ArgumentError, "guess what?" unless n.respond_to? :to_i
    @guessed = true
    @rooms[n.to_i] == :car # true == win_the_car
  end

  # convenience methods for the doors
  def first  ; @rooms[0] unless encapsulation_check ; end
  def middle ; @rooms[1] unless encapsulation_check ; end
  def last   ; @rooms[2] unless encapsulation_check ; end

  def inspect
    "<#{self.class.name}:#{self.class.object_id} #{@rooms.collect {|c| s = "[%4s]" % (@guessed ? c : '----') }.join ' '}>"
  end
end

# truth table for perfect guesser
#      -- inputs --
# watch         guessing game     propositions                                             color_one                                       color_two    - final combo
# truth-color door1 door2 door3 - truth_is_yellow truth_is_blue first_and_tiy last_and_tib fiy_or_lab   not_last_and_tiy not_first_and_tib nlay_or_nfab - color1 & color2/door
# yellow      car   goat  goat    true /yellow    false/blue    true /yellow  false/blue   true /yellow true /yellow     false/blue        true /yellow - yellow & yellow/first
# yellow      goat  car   goat    true /yellow    false/blue    false/blue    false/blue   false/blue   true /yellow     false/blue        true /yellow - blue   & yellow/middle
# yellow      goat  goat  car     true /yellow    false/blue    false/blue    false/blue   false/blue   false/blue       false/blue        false/blue   - blue   & blue  /last
# blue        car   goat  goat    false/yellow    true /blue    false/yellow  false/yellow false/yellow false/yellow     false/yellow      false/yellow - yellow & yellow/first
# blue        goat  car   goat    false/yellow    true /blue    false/yellow  false/yellow false/yellow false/yellow     true /blue        true /blue   - yellow & blue  /middle
# blue        goat  goat  car     false/yellow    true /blue    false/yellow  true /blue   true /blue   false/yellow     true /blue        true /blue   - blue   & blue  /last
#
# c1 == c2 == :yellow   c1 != c2            c1 == c2 == :blue
# first-door            middle-door         last-door
$guesser = lambda {|game, watch|

  prop :door1 do game.first  == :car end
  prop :door2 do game.middle == :car end
  prop :door3 do game.last   == :car end

  prop :truth_is_yellow do watch.truth_color == :yellow end
  prop :truth_is_blue   do watch.truth_color == :blue   end

   first_color = watch.ask { ( door1           && truth_is_yellow) || (          door3  && truth_is_blue) }
  second_color = watch.ask { ((door1 || door2) && truth_is_yellow) || ((door2 || door3) && truth_is_blue) }

  guess = if first_color != second_color
    1
  elsif first_color == :yellow
    0
  else
    2
  end
  p [:the_setup, game, watch] # this is peeking - no fair...
  p [first_color, :and, second_color, :therefore, guess]
  guess
}

# $dgl = lambda {|game, watch|
# 
#   door1 = lambda { game.first  == :car }
#   door2 = lambda { game.middle == :car }
#   door3 = lambda { game.last   == :car }
# 
#   truth_is_yellow = lambda { watch.truth_color == :yellow }
#   truth_is_blue   = lambda { watch.truth_color == :blue   }
# 
#    first_color = watch.ask { ( door1.call                && truth_is_yellow.call) || (               door3.call  && truth_is_blue.call) }
#   second_color = watch.ask { ((door1.call || door2.call) && truth_is_yellow.call) || ((door2.call || door3.call) && truth_is_blue.call) }
# 
#   guess = if first_color != second_color
#     1
#   elsif first_color == :yellow
#     0
#   else
#     2
#   end
#   p [:the_setup, game, watch]
#   p [first_color, :and, second_color, :therefore, guess]
#   guess
# }
