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

end
