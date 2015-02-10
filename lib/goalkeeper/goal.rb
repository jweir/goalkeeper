module Goalkeeper
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

    # ttl returns the time to live on the redis key
    def ttl
      Goalkeeper.redis.ttl self.key
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
