require 'test_helper'

describe Goalkeeper do
  before do
    Goalkeeper.redis.flushdb
  end

  describe "::redis" do
    it "returns the Redis client" do
      assert Goalkeeper.redis.is_a?(Redis)
    end
  end

  describe "::namespace" do
    it "defaults to Goalkeeper" do
      assert_equal "Goalkeeper", Goalkeeper.namespace
    end

    it "can be user defined" do
      ns = Goalkeeper.namespace

      Goalkeeper.namespace = "NewNamespace"
      assert_equal "NewNamespace", Goalkeeper.namespace
      goal = Goalkeeper::Goal.new("x")
      assert_equal "NewNamespace:x", goal.key

      # reset
      Goalkeeper.namespace = ns
    end
  end

  describe Goalkeeper::List do
    before do
      @goals = Goalkeeper::List.new
    end

    describe "#add" do
      it "creates a Goal from the label" do
        @goals.add("a:1")
        assert_equal 1, @goals.size
        assert_equal "a:1", @goals[0].label
      end

      it "accepts an option expiration" do
        @goals.add("a:1", expiration: 20)
        assert_equal 20, @goals.first.expiration
      end

      it "should return itself (so it is chainable)" do
        assert_equal @goals, @goals.add("a:1")
      end
    end

    describe "with goals" do
      before do
        @goals.add("x").add("y")
      end

      describe "#met" do
        it "returns all Goals which have been met" do
          assert @goals.met.empty?
          @goals[0].met!
          assert_equal ["x"], @goals.met.map(&:label)
          @goals[1].met!
          assert_equal ["x","y"], @goals.met.map(&:label)
        end
      end

      describe "#unmet" do
        it "returns all Goals which have not been met" do
          assert_equal ["x","y"], @goals.unmet.map(&:label)
          @goals[0].met!
          assert_equal ["y"], @goals.unmet.map(&:label)
          @goals[1].met!
          assert @goals.unmet.empty?
        end
      end

      describe "#met?" do
        it "is true when all Goals have been met" do
          assert ! @goals.met?
          @goals.each(&:met!)
          assert @goals.met?
        end
      end
    end
  end

  describe Goalkeeper::Goal do
    before do
      @goal = Goalkeeper::Goal.new("b")
    end

    it "has a label" do
      assert_equal "b", @goal.label
    end

    it "has a namespaced key" do
      assert_equal "Goalkeeper:b", @goal.key
    end

    it "is met? if the label has a Redis record" do
      assert ! @goal.met?
      Goalkeeper.redis.set @goal.key, Time.now
      assert @goal.met?
    end

    describe "met_at" do
      it "is nil if the Goal is not met" do
        assert_equal nil, @goal.met_at
      end

      it "is the timestamp that the Goal was met" do
        @t = Time.parse(Time.now.to_s)
        @goal.met!
        assert_equal @t, @goal.met_at
      end
    end

    describe "#met!" do
      it "creates a Redis record" do
        assert Goalkeeper.redis.get(@goal.key).nil?
        @goal.met!
        assert ! Goalkeeper.redis.get(@goal.key).nil?
      end

      it "has a default ttl expiration" do
        @goal.met!
        assert_equal @goal.expiration, Goalkeeper.redis.ttl(@goal.key) 
      end
    end

    describe "#expiration" do
      it "has a default of 24 hours" do
        assert_equal 24 * 60 * 60, @goal.expiration
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
      end
    end
  end
end
