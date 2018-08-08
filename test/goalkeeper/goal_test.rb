require 'test_helper'

describe Goalkeeper::Goal do
  before do
    Goalkeeper.redis.flushdb
  end

  let(:goal) { Goalkeeper::Goal.new("test") }

  it "has a label" do
    assert_equal "test", goal.label
  end

  describe "label" do
    it "can be a string" do
      g = Goalkeeper::Goal.new("a_string")
      assert_equal 'a_string', g.label
    end

    it "will join multiple args into a string seperated by ':'" do
      g = Goalkeeper::Goal.new("a", :b, Object)
      assert_equal 'a:b:Object', g.label
    end
  end

  it "has a namespaced key" do
    assert_equal "Goalkeeper:test", goal.key
  end

  it "is met? if the label has a Redis record" do
    assert !goal.met?
    Goalkeeper.redis.set goal.key, Time.now
    assert goal.met?
  end

  describe "met_at" do
    it "is nil if the Goal is not met" do
      assert_nil goal.met_at
    end

    it "is the timestamp that the Goal was met" do
      @t = Time.parse(Time.now.to_s)
      goal.met!
      assert_equal @t, goal.met_at
    end
  end

  describe "#met!" do
    it "creates a timestamp record with the Goal's key" do
      Time.stub(:now, 'timestamp') do
        assert_nil Goalkeeper.redis.get(goal.key)
        goal.met!
        assert_equal 'timestamp', Goalkeeper.redis.get(goal.key)
      end
    end

    it "has a default ttl expiration" do
      goal.met!
      assert_equal goal.expiration, Goalkeeper.redis.ttl(goal.key)
    end

    it "does nothing if the goal is already met" do
      t = Time.now
      Time.stub(:now, t) do
        goal.met!
        assert_equal Time.parse(t.to_s), goal.met_at
      end

      Time.stub(:now, t + 1000) do
        goal.met!
        assert_equal Time.parse(t.to_s), goal.met_at
      end
    end
  end

  describe "#clear!" do
    it "removes the met state of the Goal" do
      goal.met!
      assert_equal true, goal.met?
      goal.clear!
      assert_equal false, goal.met?
    end
  end

  describe "#expiration" do
    it "has a default of 24 hours" do
      assert_equal 24 * 60 * 60, goal.expiration
    end

    it "can be set at initialization" do
      g = Goalkeeper::Goal.new("x", expiration: 60)
      assert_equal 60, g.expiration
    end
  end

  describe "equality" do
    it "should be true when the labels are the same" do
      a = Goalkeeper::Goal.new("a")
      b = Goalkeeper::Goal.new("b")
      a2 = Goalkeeper::Goal.new("a")

      assert_equal a, a2
      assert a != b
    end
  end

  describe "#ttl" do
    it "returns the ttl on the Redis record" do
      a = Goalkeeper::Goal.new("a")
      assert_equal(-2, a.ttl)
      a.met!
      assert_equal Goalkeeper.expiration, a.ttl
    end
  end
end
