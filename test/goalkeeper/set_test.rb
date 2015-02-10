require 'test_helper'

describe Goalkeeper::Set do
  before do
    Goalkeeper.redis.flushdb
  end

  let(:goals) { Goalkeeper::Set.new }

  describe "#add" do
    it "creates a Goal from the label" do
      goals.add("a:1")
      assert_equal 1, goals.size
      assert_equal "a:1", goals[0].label
    end

    it "accepts an option expiration" do
      goals.add("a:1", expiration: 20)
      assert_equal 20, goals.first.expiration
    end

    it "should return itself (so it is chainable)" do
      assert_equal goals, goals.add("a:1")
    end
  end

  it "behaves as a unique set" do
    goals << Goalkeeper::Goal.new("a")
    goals << Goalkeeper::Goal.new("b")
    goals << Goalkeeper::Goal.new("a")
    goals.push Goalkeeper::Goal.new("a")

    assert_equal 2, goals.size
  end

  it "ignores insertion of nonGoals" do
    goals << "a"
    goals.push 1, 2, :a
    assert_equal 0, goals.size
  end

  describe "with goals" do
    before do
      goals.add("x").add("y")
    end

    describe "#met" do
      it "returns all Goals which have been met" do
        assert goals.met.empty?
        goals[0].met!
        assert_equal ["x"], goals.met.map(&:label)
        goals[1].met!
        assert_equal(%w( x y ), goals.met.map(&:label))

        assert goals.met.is_a?(Goalkeeper::Set)
      end
    end

    describe "#unmet" do
      it "returns all Goals which have not been met" do
        assert_equal(%w( x y ), goals.unmet.map(&:label))
        goals[0].met!
        assert_equal ["y"], goals.unmet.map(&:label)
        goals[1].met!
        assert goals.unmet.empty?

        assert goals.unmet.is_a?(Goalkeeper::Set)
      end
    end

    describe "#met?" do
      it "is true when all Goals have been met" do
        assert !goals.met?
        goals.each(&:met!)
        assert goals.met?
      end
    end

    describe "#met_at" do
      it "is nil unless all Goals are met"
      it "is the most recent met_at from the Goals"
    end

    describe "#clear!" do
      it "calls clear on Goals"
    end
  end
end
