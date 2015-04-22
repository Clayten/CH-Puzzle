require 'ch/puzzles/games'
module CH::Puzzles::MagicWatch
  class GuessingGame < CH::Puzzles::Games
    private

    def self.default_oracle_type ; MagicWatch ; end
    def self.default_puzzle_type ; PrizeCabinet ; end

    def state ; puzzle.send :state ; end
    def check n ; (0...puzzle.size) === n ; end

    def self.options_from_args color, door_number, &b
      { :truth_value => color, :prize_location => door_number }
    end

    public

    def state_items ; [ oracle, puzzle ] ; end

    def initialize options = {}
      super
      options[:resettable] = false
      puzzle options.dup
    end

    class RecursiveGuessingGame < GuessingGame
      def initialize options = {}
        super options.merge(:free_recursion => true)
      end
    end
  end
end
