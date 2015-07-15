require 'ch/puzzles/utils'
module CH::Puzzles
  class Items
    class SequenceViolation < RuntimeError ; end
    include CH::Puzzles::Resettable
    include CH::Puzzles::Encapsulated
    def enforce_no_guessing_while_asking ; refute_encapsulation ; end

    def enforce_single_guess             ; raise SequenceViolation, "can't guess more than once" if     @guessed ; end

    def state ; nil ; end

    def check answer ; raise ArgumentError, "Return value of play block (#{answer.inspect}) isn't in known states: #{states}" unless states.include? answer ; end

    public

    attr_reader :guessed

    def self.states ; [] ; end
    def      states ; self.class.states ; end

    def reset
      super
      reset_state
    end

    def guess answer
      check answer
      enforce_no_guessing_while_asking
      enforce_single_guess
      @guessed = true
      answer == state
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
