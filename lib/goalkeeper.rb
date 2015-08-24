require 'forwardable'
require 'redis'
require 'time' # for Time.parse

# Goalkeeper provides methods to track if specific events(Goals) have been
# completed(met).
#
# Its goes likes this..
#    
# Lets ensure we wakeup New Years Day 2020.  The goal will be called 'wakeup:2020-01-01'
#   g = Goalkeeper::Goal.new('wakeup:2020-01-01')
#   g.met? #=> false
#
# Time flies... it is New Years Day 2020.
#   g.met! # or Goalkeeper.met!('wakeup:2020-01-01')
#   g.met? #=> true
#   g.met_at #=> 2020-01-01 05:01:31 -0500
#
# Now if our application checks our goal, it will be met.
#   Goalkeeper::Goal.new('wakeup:2020-01-01').met? #=> true
#   Goalkeeper.met?('wakeup:2020-01-01') #=> true
#   
# Note: Once a Goal is 'met' the 'met_at' timestamp will not change, unless
# 'clear!' is called.
#
# We are probably only interested in this goal being complete for a limited
# time, so it will expire and be removed from Redis.
#   g.ttl #=> 86400 (1 day)
#
# If you need to reference the Redis key
#   g.key #=> Goalkeeper:wakeup:2020-01-01
#
# Finally clear the Goal is simple
#   g.clear!
#
# === Sets
#
# Perhaps you have a series of Goals you want to track, and see if they all have been met, or not.
#
#   set = Goalkeeper::Set.new
#   set.add('goal1').add('goal2')
#   set.met? #=> false
#
# Lets have 1 goal met:
#   Goalkeeper.met!('goal1')
#
# But our set is not met yet
#   set.met? #=> false
#
# See which goals are met, or unmet
#   set.met #=> [#<Goalkeeper::Goal @label="goal1">]
#   set.unmet #=> [#<Goalkeeper::Goal @label="goal2">]
#
# Lets complete our set.
#   Goalkeeper.met!('goal1')
#   set.met? #=> true
#
# See the time the final goal was met
#   set.met_at #=> 2015-01-01 08:02:15 -0500
#
# === Customization
#
# Customize the redis client by setting it in your application
#   Goalkeeper.redis = your_redis_client
#
# Each record has a default expiration of 24 hours, but this can be modified.
#   Goalkeeper.expiration = number_of_seconds
#
# Redis keys are stored under the default namespace of "Goalkeeper:". The
# namespace can be configured:
#   Goalkeeper.namespace = string
#
module Goalkeeper
  require "goalkeeper/version"
  require "goalkeeper/goal"
  require "goalkeeper/set"

  # Set the Redis client to a non default setting
  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis ||= Redis.new
  end

  # Creates a persistent Goal market with the given label.
  def self.met!(*label)
    Goal.new(*label).met!
  end

  def self.met?(*label)
    Goal.new(*label).met?
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
end
