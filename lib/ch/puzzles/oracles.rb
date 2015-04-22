require 'ch/puzzles/utils'
module CH::Puzzles
  class Oracles
    class ImproperQuestion       < ArgumentError ; end
    class EncapsulationViolation < RuntimeError ; end

    include CH::Puzzles::Resettable

    private

    def self.encapsulation_signature ; /\`ask'/ ; end
    def self.encapsulation_level   ; caller.select {|c| c =~ encapsulation_signature }.length ; end
    def self.encapsulation_check   ; !encapsulation_level.zero? ; end
    def self.enforce_encapsulation ; raise EncapsulationViolation, "You can't look directly"                  unless encapsulation_check ; end
    def self.refute_encapsulation  ; raise EncapsulationViolation, "You cannot modify anything while asking"  if     encapsulation_check ; end
    def      encapsulation_level   ; self.class.encapsulation_level   ; end
    def      enforce_encapsulation ; self.class.enforce_encapsulation ; end
    def       refute_encapsulation ; self.class.refute_encapsulation  ; end

    public

    def self.truth_values ; [true, false]        ; end
    def      truth_values ; self.class.truth_values ; end
    def self.states ; truth_values ; end
    def      states ; self.class.states ; end

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
      @t, @f = truth_values
      reset
    end

    def inspect s = '...'
      "<#{self.class.name}:#{object_id} #{'trial-mode ' if trial_mode}#{s}>"
    end
  end
end
