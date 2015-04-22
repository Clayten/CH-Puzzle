require 'test/unit'
require 'shoulda-context'
require 'ch/puzzles/magic_watch/cabinet'

$LOAD_PATH << Dir.pwd

class TestCabinet < Test::Unit::TestCase
  class EncapsulationViolation < RuntimeError ; end

  def create_fake_encapsulator rtrn
    enc = "fake"
    enc.define_singleton_method(:enforce_encapsulation) { rtrn || raise(EncapsulationViolation) }
    enc.define_singleton_method( :refute_encapsulation) { rtrn && raise(EncapsulationViolation) }
    enc
  end

  def setup
    @class = CH::Puzzles::MagicWatch::PrizeCabinet
    @pc = @class.new :encapsulator => :none
  end

  should "return its size, and good/bad prizes" do
    assert_equal [@class.default_good_prize, @class.default_bad_prize], @pc.prizes
    assert_equal @class.default_size, @pc.size
  end

  context "when examined directly" do
    setup do
      @pc = @class.new :encapsulator => create_fake_encapsulator(false)
    end

    should "not allow you to ask questions about what's in the rooms" do
      assert_raises(EncapsulationViolation) { @pc.first == @pc.last }
    end

    should "allow you to guess which room contains the good prize" do
      assert_nothing_raised { @pc.guess 1 }
    end

    should "not allow you to peek until you've guessed" do
      assert_raises(@class::SequenceViolation) { @pc.peek }
      assert_nothing_raised { @pc.guess 1 }
      assert_nothing_raised { @pc.peek }
    end

    should "not allow you to guess twice" do
      assert_nothing_raised { @pc.guess 1 }
      assert_raises(@class::SequenceViolation) { @pc.guess 1 }
    end

  end
  context "when examined via an encapsulator" do

    setup do
      @pc = @class.new :encapsulator => create_fake_encapsulator(true)
    end

    should "allow you to ask questions about what's in the rooms" do
      assert_nothing_raised { @pc.first == @pc.last }
    end

    should "not allow you to guess which room contains the good prize" do
      assert_raises(EncapsulationViolation) { @pc.guess 1 }
    end

  end
end
