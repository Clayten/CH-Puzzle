module CH::Puzzle
  class Puzzle
    class SequenceViolation < RuntimeError ; end
    include Resettable
    private

    attr_reader :encapsulator

    def self.default_encapsulator ; Oracle ; end
    def      default_encapsulator ; self.class.default_encapsulator ; end

    def    enforce_encapsulation  ; encapsulator.send :enforce_encapsulation ; end
    def     refute_encapsulation  ; encapsulator.send :refute_encapsulation  ; end

    def enforce_no_guessing_while_asking ; refute_encapsulation ; end

    def enforce_single_guess             ; raise SequenceViolation, "can't guess more than once" if     @guessed ; end

    def state ; nil ; end

    public

    def self.states ; [] ; end
    def      states ; self.class.states ; end

    def guess x
      raise ArgumentError, "guess what?" unless states.include? x
      enforce_no_guessing_while_asking
      enforce_single_guess
      @guessed = true
      x == state
    end

    def trial_mode ; false ; end

    def initialize options = {}
      @encapsulator  = options.delete(:encapsulator) || default_encapsulator
      reset
    end

    def inspect s = '...'
      "<#{self.class.name}:#{self.class.object_id} #{'trial-mode ' if trial_mode}#{s}>"
    end
  end
end

module CH::Puzzle::Liars
  class Road < CH::Puzzle::Puzzle
    private

    def state ; @direction ; end

    public

    def self.directions ; [:left, :right] ; end
    def self.states ; directions ; end

    def reset
      super
      if nil != @forced_direction
        raise ArgumentError, "The road doesn't fork #{@forced_direction}" unless states.include? @forced_direction
        @direction = @forced_direction
      else
        @direction = self.class.directions.shuffle.first
      end
      @guessed = false
      nil
    end

    def direction
      enforce_encapsulation
      @direction
    end

    def trial_mode ; nil != forced_direction ; end

    def initialize options = {}
      @forced_direction = options.delete(:direction) if options.include? :direction
      super
    end
  end
end

module CH::Puzzle::MagicWatch
  class PrizeCabinet < CH::Puzzle::Puzzle
    private
    def self.default_size         ; 3          ; end
    def self.default_bad_prize    ; :goat      ; end
    def self.default_good_prize   ; :car       ; end
    def      default_size         ; self.class.default_size         ; end
    def      default_bad_prize    ; self.class.default_bad_prize    ; end
    def      default_good_prize   ; self.class.default_good_prize   ; end

    def state ; @rooms.index good_prize ; end

    attr_reader :forced_prize_location, :forced_layout 
    
    public

    attr_reader :size, :guessed, :prizes, :bad_prize, :good_prize

    def self.states ; (0...default_size).to_a ; end
    def      states ; (0...        size).to_a ; end

    def prizes ; [good_prize, bad_prize] ; end

    def reset
      super
      if nil != forced_layout
        raise ArgumentError, "specifying a layout and a prize_location doesn't make any sense" if forced_prize_location
        raise ArgumentError, "specifying a layout and a size is either redundant or wrong"     if size
        @rooms = forced_layout
      else
        raise ArgumentError, "Room ##{forced_prize_location} is outside the cabinet" if forced_prize_location and forced_prize_location < 0 || forced_prize_location >= size # note 'and'
        @rooms = [bad_prize] * size
        @rooms[forced_prize_location || rand(size)] = good_prize
      end
      @guessed = false
      nil
    end

    def trial_mode ; (nil != forced_layout || nil != forced_prize_location) ; end

    def rooms
      enforce_encapsulation
      @rooms
    end

    # convenience methods for the doors
    def first  ; rooms[ 0] ; end
    def middle ; rooms[ 1] ; end
    def last   ; rooms[-1] ; end

    def initialize options = {}
      @bad_prize      = options.include?(:bad_prize ) ? options.delete(:bad_prize ) : default_bad_prize
      @good_prize     = options.include?(:good_prize) ? options.delete(:good_prize) : default_good_prize
      @size           = options.include?(:size      ) ? options.delete(:size)       : default_size
      @forced_layout         = options.delete(:layout)         if options.include? :layout
      @forced_prize_location = options.delete(:prize_location) if options.include? :prize_location
      super
    end

    def inspect
      super "#{@rooms.collect {|c| s = "[%4s]" % (@guessed ? c : '----') }.join ' '}"
    end
  end
end
