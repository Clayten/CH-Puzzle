require 'ch/puzzles/utils'
module CH::Puzzles
  class Items
    class SequenceViolation < RuntimeError ; end
    include CH::Puzzles::Resettable
    private

    attr_reader :encapsulator

    def self.default_encapsulator ; Oracles ; end
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
