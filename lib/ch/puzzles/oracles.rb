require 'ch/puzzles/utils'
module CH::Puzzles
  class Oracles
    class ImproperQuestion       < ArgumentError ; end
    class NotEnoughQuestions     < RuntimeError ; end

    public

    extend  CH::Puzzles
    utilize CH::Puzzles::Resettable
    utilize CH::Puzzles::Encapsulator
    utilize CH::Puzzles::Stateful

    has_attribute :truth_color,         [:blue, :yellow], hidden: true,  locked: true
    has_attribute :available_questions, [ 2],             hidden: false, locked: true
    alias daily_questions available_questions

    def self.truth_values ; [true, false]        ; end
    def      truth_values ; self.class.truth_values ; end
    def self.states ; truth_values ; end
    def      states ; self.class.states ; end

    def reset
      super
      reset_state
    end

    def truth_value
      enforce_encapsulation
      @t
    end

    def ask *a
      answer = yield *a
      raise ImproperQuestion, "Only true/false questions" unless [true, false].include? answer
      answer ? @t : @f
    end

    def trial_mode ; false ; end

    def initialize options = {}
      super
      @t, @f = truth_values
      reset
    end

    def inspect s = '...'
      "<#{self.class.name}:#{object_id} #{'trial-mode ' if trial_mode}#{s}>"
    end
  end
end
