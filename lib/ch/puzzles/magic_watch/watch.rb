require 'ch/puzzles/oracles'
module CH::Puzzles::MagicWatch
  class MagicWatch < CH::Puzzles::Oracles
    has_attribute :truth_color,         [:blue, :yellow], wraps: :truth_value
    has_attribute :daily_questions,                       wraps: :available_questions

    attr_reader :daily_questions, :remaining_questions, :free_recursion

    def reset_message ; "You wait - the clock chimes midnight - the watch clicks as it resets" ;  end

    def reset
      super
      # if @forced_truth_color
      #   raise ArgumentError, "The truth value must be one of #{truth_values.inspect}" unless truth_values.include? @forced_truth_color
      #   @t, @f = @forced_truth_color, truth_values.find {|tv| tv != @forced_truth_color }
      # else
      #   @t, @f = truth_values.shuffle
      # end
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
      p [:init, self, options]
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
