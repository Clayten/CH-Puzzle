module CH::Puzzle::MagicWatch
  class PrizeCabinet
    class SequenceViolation < RuntimeError ; end
    private
    def enforce_no_peeking               ; raise SequenceViolation, "can't peek until you guess" unless @guessed ; end
    def enforce_single_guess             ; raise SequenceViolation, "can't guess more than once" if     @guessed ; end
    def enforce_no_guessing_while_asking ; refute_encapsulation ; end

    def    enforce_encapsulation  ; encapsulator.send :enforce_encapsulation ; end
    def     refute_encapsulation  ; encapsulator.send :refute_encapsulation  ; end

    def self.default_encapsulator ; MagicWatch ; end
    def self.default_size         ; 3          ; end
    def self.default_bad_prize    ; :goat      ; end
    def self.default_good_prize   ; :car       ; end
    def      default_encapsulator ; self.class.default_encapsulator ; end
    def      default_size         ; self.class.default_size         ; end
    def      default_bad_prize    ; self.class.default_bad_prize    ; end
    def      default_good_prize   ; self.class.default_good_prize   ; end

    attr_reader :encapsulator
    
    public

    attr_reader :guessed, :bad_prize, :good_prize

    def prizes ; [good_prize, bad_prize] ; end
    def size ; @rooms.length ; end

    def initialize options = {}
      @encapsulator  = options.delete(:encapsulator) || default_encapsulator
      @bad_prize     = options.delete(:bad_prize )   || default_bad_prize
      @good_prize    = options.delete(:good_prize)   || default_good_prize
      size           = options.delete(:size)         || default_size
      prize_location = options.delete(:prize_location)
      layout         = options.delete(:layout)
      @trial_mode = !!(layout || prize_location) # has this been rigged for a trial?
      if layout
        raise ArgumentError, "specifying a layout and a prize_location doesn't make any sense" if layout && prize_location
        raise ArgumentError, "specifying a layout and a size is either redundant or wrong"     if layout && size
        @rooms = layout[0...size] + ([bad_prize] * [(size - layout.size), 0].min)
      else
        raise ArgumentError, "Room ##{prize_location} is outside the cabinet" if prize_location and prize_location < 0 || prize_location >= size # note 'and'
        @rooms = [bad_prize] * size
        @rooms[prize_location || rand(size)] = good_prize
      end
      @guessed = false
    end

    def peek
      enforce_no_peeking
      @rooms
    end

    def guess n
      enforce_no_guessing_while_asking
      enforce_single_guess
      raise ArgumentError, "guess what?" unless n.respond_to? :to_i
      @guessed = true
      @rooms[n.to_i] == :car # true == win_the_car
    end

    # convenience methods for the doors
    def first  ; enforce_encapsulation ; @rooms[ 0] ; end
    def middle ; enforce_encapsulation ; @rooms[ 1] ; end
    def last   ; enforce_encapsulation ; @rooms[-1] ; end

    # don't leak info
    def inspect
      "<#{self.class.name}:#{self.class.object_id} #{'trial-mode ' if @trial_mode}#{@rooms.collect {|c| s = "[%4s]" % (@guessed ? c : '----') }.join ' '}>"
    end
  end
end
