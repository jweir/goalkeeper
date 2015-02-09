require "goalkeeper/version"
require 'forwardable'
require 'redis'
require 'time' # for Time.parse

# Goalkeeper provides methods to track if specific events(Goals) have been completed(met).
#
# It is not a complicated system and it is easy enough to roll your own.  This
# is an extraction from a system Pharos EI has been using.
#
# A Goal is just a unique string. It is up to your application to
# define any schema for the Goal's label.
#
# For example you might have your Goals labeled by date and company id:
#   "job:2016-01-17:company:7"
#
# When a Goal is met a record is created in Redis with a timestamp, this is the only
# persistent layer.
#   Goalkeeper.met!("jobkey")
#   # or
#   Goalkeeper::Goal.new("jobkey").met!
#
# To check if a Goal as been met
#   Goalkeeper::Goal.new("jobkey").met?
#
# Customize the redis client by setting it in your application
#   Goalkeeper.redis = your_redis_client
#
# Each record has a default expiration of 24 hours, but this can be modified.
#   Goalkeeper.expiration = number_of_seconds
#
# Redis keys are stored under the default namespace of "Goalkeeper:". The namespace can be configured:
#
#   Goalkeeper.namespace = string
#
class Goalkeeper

  # Set the Redis client to a non default setting
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

  # The TTL set for each met Goal record created in Redis
  # Default is 24 hours
  def self.expiration
    @expiration ||= 24 * 60 * 60
  end

  # Overwrite the default expiration
  def self.expiration=(number_of_seconds)
    @expiration = number_of_seconds
  end

  def self.namespace
    @namespace ||= "Goalkeeper"
  end

  def self.namespace=(ns)
    @namespace = ns
  end

  # List is a collection of Goals to simplify tracking multiple goals.
  #
  # Create a new list
  #   mylist = Goalkeeper::List.new
  #
  # Add Goals you want to check for completion
  #   mylist.add("job1").add("job2")
  #   mylist.size
  #   #=> 2
  #
  # Check if all the goals are completed
  #   mylist.met?
  #   #=> false
  #
  # Get the unmet Goals
  #   mylist.unmet
  #   #=> [...]
  #
  # Get the met Goals
  #   mylist.met
  #   #=> [...]
  #
  # Iterate all Goals
  #   myslist.each {|goal| ...}
  #   myslist.map  {|goal| ...}
  class List < Array
    def initialize
      super
    end

    # Creates a new Goal.
    # see Goal#initialize for usage
    def add(*args)
      self.push(Goal.new(*args))
      self
    end

    # met? returns true if all Goals in the set have been met.
    def met?
      unmet.empty?
    end

    def unmet
      self.select {|g| ! g.met?}
    end

    def met
      self.select {|g| g.met?}
    end
  end

  class Goal
    # The unique label to identify this Goal
    attr_reader :label

    # the TTL value for the Redis record.  Defalts to Goalkeeper.expiration
    attr_reader :expiration

    # +label+ is a unique string to identify this Goal.
    # There is no checking if it is truly unique.
    #
    # +expiration+ can be set to override the gobal expiratin.
    def initialize(label, expiration: Goalkeeper.expiration)
      @label = label
      @expiration = expiration
    end

    def met!
      write
      self
    end

    def met?
      ! read.nil?
    end

    # Time the goal was completed.
    # WARNING retuns nil if the job is not met
    def met_at
      if met?
        Time.parse(read)
      else
        nil
      end
    end

    # a namespaced key for the goal
    def key
      "#{Goalkeeper.namespace}:#{label}"
    end

    # All Goalkeeper::Goals with the same label are equal
    def ==(other)
      other.is_a?(Goalkeeper::Goal) && other.label == label
    end

    protected

    def write
      Goalkeeper.redis.set(self.key, Time.now)
      Goalkeeper.redis.expire(self.key, self.expiration)
    end

    def read
      Goalkeeper.redis.get self.key
    end
  end
end
