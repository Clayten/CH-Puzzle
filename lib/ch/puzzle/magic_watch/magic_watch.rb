module CH::Puzzle
  module Resettable
    class ResetNotAllowed < RuntimeError ; end

    private

    def reset_name ; self.class.name.split('::').last ; end
    def reset_message ; "The #{reset_name} has been reset" ; end
    def reset_fail_message ; "The #{reset_name} cannot be reset" ; end

    def initializing?
      caller.any? {|c| c =~ /`initialize'/ }
    end

    def count_reset
      @reset_count ||= 0
      @reset_count += 1
    end

    def reset_check
      raise ResetNotAllowed, reset_fail_message unless (initializing? || resettable)
    end

    def reset
      reset_check
      count_reset        unless initializing?
      puts reset_message unless initializing?
    end

    public

    def resettable ; (@resettable != nil) ? @resettable : true ; end
  end
      
  class Oracle
    include Resettable

    class ImproperQuestion       < ArgumentError ; end
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

module CH::Puzzle::Liars
  class Villager < CH::Puzzle::Oracle
    private

    def state ; states[truth_values.index @t] ; end

    public

    def self.states ; [ :honest, :liar ] ; end

    def reset
      super
      if nil != @forced_honesty
        raise ArgumentError, "I don't know the #{@forced_honesty} tribe" unless self.class.states.include? @forced_honesty
        if :honest == @forced_honesty
          @will_lie = false
        else
          @will_lie = true
        end
      else
        @will_lie = rand(2).zero?
      end
      @t, @f = @will_lie ? truth_values : truth_values.reverse
    end

    def will_lie?
      enforce_encapsulation
      @will_lie
    end

    def trial_mode ; nil != @forced_honesty ; end

    def initialize options = {}
      @forced_honesty = options.delete(:forced_honesty) if options.include? :forced_honesty
      @resettable       = options.include?(:resettable) ? options.delete(:resettable) : false
      super
    end
  end
end

module CH::Puzzle::MagicWatch
  class MagicWatch < CH::Puzzle::Oracle
    class NotEnoughQuestions     < RuntimeError ; end
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

    def self.truth_values ; [:yellow, :blue] ; end

    def resettable ; (@resettable != nil) ? @resettable : true ; end

    attr_reader :daily_questions, :remaining_questions, :free_recursion

    def reset_message ; "You wait - the clock chimes midnight - the watch clicks as it resets" ;  end

    def reset
      super
      if @forced_truth_color
        raise ArgumentError, "The truth value must be one of #{truth_values.inspect}" unless truth_values.include? @forced_truth_color
        @t, @f = @forced_truth_color, truth_values.find {|tv| tv != @forced_truth_color }
      else
        @t, @f = truth_values.shuffle
      end
      @remaining_questions = @daily_questions
    end

    def trial_mode ; nil != @forced_truth_color ; end
      
    def truth_color
      truth_value
    end

    def ask *a
      raise NotEnoughQuestions, "The watch lies dead, good job" if remaining_questions.zero? unless ((encapsulation_level - 1) > 0) && free_recursion
      deducted = @remaining_questions -= 1 if (encapsulation_level - 1).zero? || !free_recursion # the first question always costs, recursive questions may not cost further
      super
    rescue
      @remaining_questions += 1 if deducted # failed questions don't count, but only refund if we charged
      raise
    end

    def trial_mode ; nil != @forced_truth_color ; end

    def initialize options = {}
      @forced_truth_color     = options.delete(:forced_truth_color) if options.include? :forced_truth_color
      @resettable      = options.include?(:resettable    ) ? options.delete(:resettable)     : true
      @free_recursion  = options.include?(:free_recursion) ? options.delete(:free_recursion) : false
      @daily_questions = options.include?(:daily_guesses ) ? options.delete(:daily_guesses)  : 2
      super
    end

    def inspect
      super "remaining_questions=#{remaining_questions}, free_recursion=#{free_recursion}"
    end
  end
end
