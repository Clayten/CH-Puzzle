require 'timeout'
module CH::Puzzle
  class Game
    private
    def self.default_oracle_type ; Oracle ; end
    def              oracle_type ; self.class.default_oracle_type ; end

    def self.default_puzzle_type ; Puzzle ; end
    def              puzzle_type ; self.class.default_puzzle_type ; end

    def check answer ; raise ArgumentError, "Return value of play block isn't in known states: #{states}, #{answer.inspect}" unless states.include? answer ; end

    # When you're given scalar args, what options do these represent? - must be the same order as state_items
    def self.options_from_args *a ; {} ; end

    public

    def      states ; state_items.reverse.collect {|i| i.states }.inject {|a,b| a.empty? ? b : b.collect {|i| a.collect {|j| [i] + [*j] } }.inject(&:+) } ; end
    def self.states options = {} ; new(options).states ; end

    def state_items ; [] ; end

    def self.play options = {}, &b
      b, options = options, {} if options.is_a? Proc
      new(options).play &b
    end

    def self.test options = {}, &b
      b, options = options, {} if options.is_a? Proc
      tests = states options
      raise ArgumentError, "There are no tests for #{name}" if tests.empty?
      total = 0
      tests.each {|args|
        result = nil
        sub_options = options_from_args *args
        begin
          Timeout.timeout(1) {
            result = play options.merge(sub_options), &b
          }
        rescue TimeoutError
          print "Strategy took too long to run. "
        rescue RuntimeError => e
          print "Strategy raised #{e.inspect}. "
        end
        if result
          total += 1
        else
          puts "Failed to handle case: #{sub_options}"
        end
      }
      Rational total, tests.length
    end

    def success? ; @success ; end

    def oracle options = {} ; @oracle ||= oracle_type.new options                                         ; end
    def puzzle options = {} ; @puzzle ||= puzzle_type.new options.merge(:encapsulator => oracle(options)) ; end

    def ask pr = nil, &b
      b ||= pr if pr.is_a? Proc
      oracle.ask &b
    end

    def guess *a ; @success = puzzle.guess *a ; end

    # define a 'proposition', a method, from a block (which remains a closure) on the game instance - for writing easier and more reusable queries
    # 
    # GuessingGame.new {|puzzle,oracle|
    #   prop :door_one_has_a_goat do puzzle.room1 == :goat end
    #   first_answer = w.ask { door_one_has_a_goat }
    #   ...
    def prop name, pr = nil, &b
      b ||= pr if pr.is_a? Proc
      define_singleton_method name, &b
    end

    def play pr = nil, &b
      b ||= pr if pr.is_a? Proc
      answer = instance_exec puzzle, oracle, &b
      check answer
      guess answer
    end

    def initialize options = {}
    end
  end
end

module CH::Puzzle::Liars
  class UnreliableVillagerGame < CH::Puzzle::Game
    attr_reader :villager, :road
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

module CH::Puzzle::MagicWatch
  class GuessingGame < CH::Puzzle::Game
    private

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

