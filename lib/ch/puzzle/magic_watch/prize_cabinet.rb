class CH::Puzzle::MagicWatch::PrizeCabinet
  class SequenceViolation < RuntimeError ; end
  def enforce_no_peeking   ; raise SequenceViolation, "can't peek until you guess" unless @guessed ; end
  def enforce_single_guess ; raise SequenceViolation, "can't guess more than once" if     @guessed ; end
  def encapsulation_check  ; encapsulator.encapsulation_check ; end

  attr_reader :encapsulator, :size, :guessed

  def initialize options = {}
    @encapsulator = options.delete(:encapsulator) || self.class.encapsulator
    @size         = options.delete(:size)       || 3
      bad_prize   = options.delete( :bad_prize) || :goat
     good_prize   = options.delete(:good_prize) || :car
    @rooms = [bad_prize] * size
    @rooms[rand size] = good_prize
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
  def first  ; @rooms[ 0] unless encapsulation_check ; end
  def middle ; @rooms[ 1] unless encapsulation_check ; end
  def last   ; @rooms[-1] unless encapsulation_check ; end

  # don't leak info
  def inspect
    "<#{self.class.name}:#{self.class.object_id} #{@rooms.collect {|c| s = "[%4s]" % (@guessed ? c : '----') }.join ' '}>"
  end
end
