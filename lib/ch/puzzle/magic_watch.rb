# require "ch/puzzle/magic_watch/version"
$LOAD_PATH << (lp = File.dirname(File.realdirpath(__FILE__)))         # FIXME
%w(version magic_watch prize_cabinet guessers/non-recursive).each {|lib| fn = "#{lp}/magic_watch/#{lib}.rb" ; "Loading #{fn}" ; load fn } # using load instead of require for reloadability

module CH
  module Puzzle
    module MagicWatch
      class GuessingGame
        def default_oracle ; MagicWatch   ; end
        def default_puzzle ; PrizeCabinet ; end
  
        def self.play options = {}, &b
          new(options).play &b
        end

        def self.test options = {}, &b
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
        def prop name, &b
          define_singleton_method name, &b
        end
      
        def play &b
          puzzle.guess instance_exec puzzle, oracle, &b
        end
  
        def oracle options = {} ; @oracle ||= oracle_type.new options                                ; end
        def puzzle options = {} ; @puzzle ||= puzzle_type.new options.merge(:encapsulator => oracle(options)) ; end
  
        attr_reader :oracle_type, :puzzle_type
        def initialize options = {}
          @oracle_type = options.delete(:oracle) || default_oracle
          @puzzle_type = options.delete(:puzzle) || default_puzzle
          puzzle options.dup
        end
      end

      class RecursiveGuessingGame < GuessingGame
        def initialize options = {}
          super options.merge(:free_recursion => true)
        end
      end
    end
  end
end
