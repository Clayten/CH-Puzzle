class CH::Puzzle::MagicWatch::MagicWatch
  class ImproperQuestion       < ArgumentError ; end
  class NotEnoughQuestions     < RuntimeError ; end
  class EncapsulationViolation < RuntimeError ; end
  def self.encapsulation_signature ; /\`ask'/ ; end
  def self.encapsulation_levels    ; caller.select {|c| c =~ encapsulation_signature }.length ; end
  def self.encapsulation_check     ; raise EncapsulationViolation, "You can't look directly" if encapsulation_levels.zero? ; end
  def      encapsulation_check     ; self.class.encapsulation_check ; end

  attr_reader :questions
    
  def initialize options = {}
    @t, @f = [:blue, :yellow].shuffle
    @free_recursion = !!options[:free_recursion]
    @questions      =   options[:num_guesses] || 2
  end

  def truth_color
    @t unless encapsulation_check # not really a conditional...
  end

  def ask *a
    raise NotEnoughQuestions, "The watch lies dead, good job" if @questions.zero?
    nesting_level = caller.select {|c| c =~ /\`ask'/ }.length
    deducted = @questions -= 1 if nesting_level.zero? || !@free_recursion # the first question always costs, recursive questions may not cost further
    answer = yield *a
    raise ImproperQuestion, "Only true/false questions" unless [true, false].include? answer
    answer ? @t : @f
  rescue
    @questions += 1 if deducted # failed questions don't count, but only refund if we charged
    raise
  end

  # don't leak info
  def inspect
    "<#{self.class.name}:#{object_id} @questions=#{@questions}, @free_recursion=#{@free_recursion}>"
  end
end
