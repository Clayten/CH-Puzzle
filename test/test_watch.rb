require 'test/unit'
require 'shoulda-context'
require 'ch/puzzle/magic_watch/magic_watch'

class TestWatch < Test::Unit::TestCase

  def setup
    @class = CH::Puzzle::MagicWatch::MagicWatch
    @mw = @class.new
  end

  should "answer true/false questions with different, though unpredictable, answers" do
    refute_equal(@mw.ask {true}, @mw.ask {false})
  end

  should "refuse to answer direct questions about itself" do
    assert_raises(@class::EncapsulationViolation) { @mw.truth_color == :yellow }
  end

  should "answer indirect questions about itself" do
    assert_nothing_raised { @mw.ask {@mw.truth_color == :yellow} }
  end

  should "answer only two questions - which by default are not free when recursive" do
    @mw.ask { @mw.ask {false} == :yellow }
    assert @mw.questions.zero?
    assert_raises(@class::NotEnoughQuestions) { @mw.ask {false} }
  end

  should "answer only true/false questions" do
    assert_raises(@class::ImproperQuestion) { @mw.ask { :the_meaning_of_life_the_universe_and_everything } }
  end


  context "when recursive" do

    should "allow any number of recursive questions for the price of one but still limits initial questions" do
      @mw = @class.new :free_recursion => true
      assert_equal 2, @mw.questions
      @mw.ask { @mw.ask {7 == 3} == @mw.ask { @mw.ask {false} == :yellow } }
      assert_equal 1, @mw.questions
      @mw.ask { @mw.ask {false} == :blue }
      assert @mw.questions.zero?
      assert_raises(@class::NotEnoughQuestions) { @mw.ask {false} }
    end

  end
end
