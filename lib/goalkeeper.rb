require "goalkeeper/version"
require 'forwardable'
require 'redis'

class Goalkeeper

  # Creates a persistent Goal market with the given label.
  def self.met!(label)
    Goal.new(label).met!
  end

  class List
    extend Forwardable
    def_delegators :@list, :size, :[]

    def initialize
      @list = []
    end

    # Creates a new Goal.
    # see Goal#new for usage
    def add(label, ref: nil)
      @list.push(Goal.new(label, ref: ref))
      self
    end

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
    attr_reader :label
    attr_reader :ref

    # +label+ is a unique string to identify this demand.
    # There is no checking if it is truly unique.
    #
    # +ref+ is an optional reference to any object.  This
    # would be used by the end user's application.
    def initialize(label, ref: nil)
      @label = label
      @ref = ref
    end

    def met!
      Store.write(self.label)
      self
    end

    def met?
      ! Store.read(self.label).nil?
    end
  end

  class Store
    EXPIRATION = 60 * 60 * 24 # 1 day

    def self.write(label)
      nl = ns(label)
      client.set nl, Time.now
      client.expire nl, EXPIRATION
    end

    def self.read(label)
      nl = ns(label)
      client.get nl
    end

    def self.remove(label)
      nl = ns(label)
      client.del nl
    end

    protected

    def self.ns(label)
      namespace + ":"+ label
    end

    def self.namespace
      "Goalkeeper"
    end

    def self.client
      @client ||= Redis.new
    end

  end
end
