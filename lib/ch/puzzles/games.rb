require 'timeout'
module CH::Puzzles
  class Games
    private
    def self.default_oracle_type ; CH::Puzzles::Oracles ; end
    def              oracle_type ; self.class.default_oracle_type ; end

    def self.default_puzzle_type ; CH::Puzzles::Items ; end
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
