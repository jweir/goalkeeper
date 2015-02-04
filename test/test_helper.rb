require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/pride'

require './lib/goalkeeper'

require './test/support/redis_instance'

# Start up Redis on a random port
Goalkeeper.redis = RedisInstance.run!

