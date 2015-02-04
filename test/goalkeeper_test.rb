require 'test_helper'

# API
# Goal.configure
# Goal.met label, ttl
# Goal::List.new
#   .add
#   .met
#   .unmet
#   .met?
#
#   configure
#     redis client
#     namespace
#
# Goal -> score, completed, met
#
# was a Goal met?
# when was it met?
describe Goalkeeper do

  describe Goalkeeper::List do
    before do
      @goals = Goalkeeper::List.new
    end

    describe "#add" do
      it "create a Goal" do
        @goals.add("a:1")
        assert_equal 1, @goals.size
        assert_equal "a:1", @goals[0].label
      end

      it "accepts an optional reference object" do
        o = Object.new
        @goals.add("a:1", ref: o)
        assert_equal o, @goals[0].ref
      end

      it "should return itself (so it is chainable)" do
        assert_equal @goals, @goals.add("a:1")
      end
    end

    describe "#met" do
      it "returns all Goals which have been met"
    end

    describe "#unmet" do
      it "returns all Goals which have not been met"
    end

    describe "#met?" do
      it "is true when all Goals have been met"
    end
  end

  describe "met!" do
    it "should create a Goal for the given label" do
      assert Goalkeeper.met!("x:1")
    end

    it "has a default ttl expiration"
    it "takes an optional at: timestamp" 
    it "takes an optional ttl for expiration" 
  end

  describe "namespace" do
  end

  describe "configuation" do
    # allow setting the redis client
  end
end

describe "Integration" do
  before do
    puts "fix this!"
    Redis.new.flushdb
  end

  it "works like this" do
    Goalkeeper.met! "x"

    d = Goalkeeper::List
      .new
      .add("x")
      .add("y")

    assert_equal false, d.met?

    assert_equal ["y"], d.unmet.map(&:label)
    assert_equal ["x"], d.met.map(&:label)

    Goalkeeper.met! "y"

    assert_equal true, d.met?

    assert_equal ["x","y"], d.met.map(&:label)
  end
end

