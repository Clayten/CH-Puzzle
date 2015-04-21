module CH::Puzzle::MagicWatch
  class GuessingGame
    private
    def default_oracle ; MagicWatch   ; end
    def default_puzzle ; PrizeCabinet ; end

    attr_reader :oracle_type, :puzzle_type

    public

    def self.play options = {}, &b
      b ||= options if options.is_a? Proc
      new(options).play &b
    end

    def self.test options = {}, &b
      b ||= options if options.is_a? Proc
      cabinet_size = options.delete(:cabinet_size) || PrizeCabinet.default_size
      truth_values = options.delete(:truth_values) || MagicWatch.truth_values
      num_tests = cabinet_size * 2
      total = 0
      truth_values.each {|color|
        0.upto(cabinet_size - 1) {|door_number|
          result = nil
          begin
            Timeout.timeout(1) {
              result = play :truth_value => color, :prize_location => door_number, &b
            }
          rescue TimeoutError
            print "Strategy took too long to run. "
          rescue RuntimeError => e
            print "Strategy raised #{e.inspect}. "
          end
          if result
            total += 1
          else
            puts "Failed to handle case: prize_location: #{door_number}, truth_value: #{color}"
          end
        }
      }
      total/1r / num_tests
    end

    # define a 'proposition', a method, from a block (remains a closure) on the game instance - for writing easier queries in game mode
    # 
    # DoorGuesser.new {|g,w|
    #   prop :door_one_has_a_goat do room1 == :goat end
    #   first_answer = w.ask { door_one_has_a_goat }
    #   ...
    def prop name, pr = nil, &b
      b ||= pr if pr.is_a? Proc
      define_singleton_method name, &b
    end

    def play pr = nil, &b
      b ||= pr if pr.is_a? Proc
      answer = instance_exec puzzle, oracle, &b
      raise ArgumentError, "Return value of play block isn't integer within (0..#{puzzle.size - 1}): #{answer.inspect}" unless (0...puzzle.size) === answer
      puzzle.guess answer
    end

    def oracle options = {} ; @oracle ||= oracle_type.new options                                ; end
    def puzzle options = {} ; @puzzle ||= puzzle_type.new options.merge(:encapsulator => oracle(options)) ; end

    def initialize options = {}
      @oracle_type = options.delete(:oracle) || default_oracle
      @puzzle_type = options.delete(:puzzle) || default_puzzle
      puzzle options.dup
    end

    class RecursiveGuessingGame < GuessingGame
      def initialize options = {}
        super options.merge(:free_recursion => true)
      end
    end
  end
end

