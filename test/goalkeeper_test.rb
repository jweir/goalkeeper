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

  let(:goal) {  Goalkeeper::Goal.new('a:b') }

  describe "::met!" do
    it "creates a goal and flags it met" do
      Goalkeeper.met!('a','b')
      assert goal.met?
    end
  end

  describe "::met?" do
    it "creates a goal and checks if it is met" do
      assert ! Goalkeeper.met?('a','b')
      goal.met!
      assert Goalkeeper.met?('a','b')
    end
  end
end
