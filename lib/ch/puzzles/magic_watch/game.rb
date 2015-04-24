require 'ch/puzzles/games'
module CH::Puzzles::MagicWatch
  class GuessingGame < CH::Puzzles::Games
    private

    def self.default_oracle_type ; MagicWatch ; end
    def self.default_puzzle_type ; PrizeCabinet ; end

    def state ; puzzle.send :state ; end
    def check n ; (0...puzzle.size) === n ; end

    def self.options_from_args color, door_number
      { :truth_value => color, :prize_location => door_number }
    end

    public

    alias watch   oracle
    alias cabinet puzzle

    def state_items ; [ watch, cabinet ] ; end

    def initialize options = {}
      super
      options[:resettable] = false
      puzzle options
    end
  end

  class RecursiveGuessingGame < GuessingGame
    def initialize options = {}
      super options.merge(:free_recursion => true)
    end
  end
end
