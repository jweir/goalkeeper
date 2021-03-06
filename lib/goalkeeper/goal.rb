module Goalkeeper
  # Goal represents a label which has either been +met+ or not.
  # 
  class Goal
    # The unique label to identify this Goal. There is no logic to check that the
    # label is unique.
    attr_reader :label

    # the TTL value for the Redis record.  Defalts to Goalkeeper.expiration
    attr_reader :expiration

    # +label+ is a unique string to identify this Goal. If multiple args are passed they are joined and seperated by ':'
    # +expiration+ number secconds. This can be set to override the gobal expiration.
    def initialize(*label, expiration: Goalkeeper.expiration)
      @label = label.join(":")
      @expiration = expiration
    end

    def met!
      write unless met?
      self
    end

    def met?
      !read.nil?
    end

    # Time the goal was completed.
    # WARNING retuns nil if the job is not met
    def met_at
      return Time.parse(read) if met?
      nil
    end

    # clear! removes the met state of the Goal.
    def clear!
      Goalkeeper.redis.del(key)
    end

    # a namespaced key for the goal
    def key
      "#{Goalkeeper.namespace}:#{label}"
    end

    # ttl returns the time to live on the redis key
    def ttl
      Goalkeeper.redis.ttl(key)
    end

    # All Goalkeeper::Goals with the same label are equal
    def ==(other)
      other.is_a?(Goalkeeper::Goal) && other.label == label
    end

    protected

    def write
      Goalkeeper.redis.set(key, Time.now)
      Goalkeeper.redis.expire(key, expiration)
    end

    def read
      Goalkeeper.redis.get(key)
    end
  end
end
