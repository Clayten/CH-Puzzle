module CH::Puzzle::MagicWatch
  class MagicWatch
    class ImproperQuestion       < ArgumentError ; end
    class NotEnoughQuestions     < RuntimeError ; end
    class EncapsulationViolation < RuntimeError ; end
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

    def self.truth_values ; [:yellow, :blue]        ; end
    def      truth_values ; self.class.truth_values ; end

    attr_reader :questions, :free_recursion
      
    def initialize options = {}
      truth_value  = options.delete(:truth_value ) || nil
      if truth_value
        raise ArgumentError, "The truth value must be one of #{truth_values.inspect}" unless truth_values.include? truth_value
        @t, @f = truth_value, truth_values.find {|tv| tv != truth_value }
        @trial_mode = true
      else
        @t, @f = truth_values.shuffle
      end
      @free_recursion = !!options[:free_recursion]
      @questions      =   options[:num_guesses] || 2
    end

    def truth_color
      enforce_encapsulation
      @t
    end

    def ask *a
      raise NotEnoughQuestions, "The watch lies dead, good job" if @questions.zero? unless ((encapsulation_level - 1) > 0) && free_recursion
      deducted = @questions -= 1 if (encapsulation_level - 1).zero? || !free_recursion # the first question always costs, recursive questions may not cost further
      answer = yield *a
      raise ImproperQuestion, "Only true/false questions" unless [true, false].include? answer
      answer ? @t : @f
    rescue
      @questions += 1 if deducted # failed questions don't count, but only refund if we charged
      raise
    end

    # don't leak info
    def inspect
      "<#{self.class.name}:#{object_id} #{'trial-mode ' if @trial_mode}@questions=#{@questions}, free_recursion=#{free_recursion}>"
    end
  end
end
