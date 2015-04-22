module CH::Puzzles::Liars

  class Villager < CH::Puzzles::Oracles
    private

    def state ; states[truth_values.index @t] ; end

    public

    def self.states ; [ :honest, :liar ] ; end

    def reset
      super
      if nil != @forced_honesty
        raise ArgumentError, "I don't know the #{@forced_honesty} tribe" unless self.class.states.include? @forced_honesty
        if :honest == @forced_honesty
          @will_lie = false
        else
          @will_lie = true
        end
      else
        @will_lie = rand(2).zero?
      end
      @t, @f = @will_lie ? truth_values : truth_values.reverse
    end

    def will_lie?
      enforce_encapsulation
      @will_lie
    end

    def trial_mode ; nil != @forced_honesty ; end

    def initialize options = {}
      @forced_honesty = options.delete(:forced_honesty) if options.include? :forced_honesty
      @resettable       = options.include?(:resettable) ? options.delete(:resettable) : false
      super
    end
  end

  class Road < CH::Puzzles::Items
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

  class UnreliableVillagerGame < CH::Puzzles::Games
    attr_reader :villager, :road
    def self.default_oracle_type ; MagicWatch ; end
    def self.default_puzzle_type ; PrizeCabinet ; end

    def state_items ; [ villager, road ] ; end

    def direction
      road.direction
    end

    def initialize options = {}
      super
      @villager = Villager.new
      @road     = Road.new
    end
  end
end
