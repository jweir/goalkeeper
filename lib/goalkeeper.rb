require "goalkeeper/version"
require 'forwardable'
require 'redis'

class Goalkeeper

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis ||= Redis.new
  end

  # Creates a persistent Goal market with the given label.
  def self.met!(label)
    Goal.new(label).met!
  end

  class List
    extend Forwardable
    def_delegators :@list, :size, :[], :each, :map

    def initialize
      @list = []
    end

    # Creates a new Goal.
    # see Goal#new for usage
    def add(label, ref: nil)
      @list.push(Goal.new(label, ref: ref))
      self
    end

    # met? returns true if all Goals in the set have been met.
    def met?
      unmet.empty?
    end

    def unmet
      @list.select {|g| ! g.met?}
    end

    def met
      @list.select {|g| g.met?}
    end
  end

  class Goal
    EXPIRATION = 60 * 60 * 24 # 1 day

    attr_reader :label

    # An optional object refrence which allows an application author to
    # associate this goal to an object. The +ref+ is not used by Goalkeeper.
    attr_reader :ref

    # the TTL value for the Redis record.  Defalts to EXPIRATION
    attr_reader :expiration

    # +label+ is a unique string to identify this demand.
    # There is no checking if it is truly unique.
    #
    # +ref+ is an optional reference to any object.  This
    # would be used by the end user's application.
    def initialize(label, ref: nil, expiration: EXPIRATION)
      @label = label
      @ref = ref
      @expiration = expiration
    end

    def met!
      Store.write(self)
      self
    end

    def met?
      ! Store.read(self).nil?
    end

    # a namespaced key for the goal
    def key
      "Goalkeeper:#{label}"
    end
  end

  class Store
    def self.write(goal)
      Goalkeeper.redis.set goal.key, Time.now
      Goalkeeper.redis.expire goal.key, goal.expiration
    end

    def self.read(goal)
      Goalkeeper.redis.get goal.key
    end

    def self.remove(goal)
      Goalkeeper.redis.del goal.key 
    end
  end
end
