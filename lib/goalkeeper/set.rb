module Goalkeeper
  # Set is a collection of Goals to simplify tracking multiple goals.
  #
  # Create a new list
  #   mylist = Goalkeeper::Set.new
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
  class Set < Array
    def initialize
      super
    end

    # Creates a new Goal.
    # see Goal#initialize for usage
    def add(*args)
      push(Goal.new(*args))
      self
    end

    # met? returns true if all Goals in the set have been met.
    def met?
      unmet.empty?
    end

    # unmet returns a Set with the all the Goals that have not been met.
    def unmet
      subset(select { |g| !g.met? })
    end

    # met returns a Set with the all the Goals that have been met.
    def met
      subset(select { |g| g.met? })
    end

    def <<(other)
      if other.is_a?(Goal) && !include?(other)
        super 
      else
        false
      end
    end

    def push(*others)
      others.each do |o|
        self << o
      end
    end

    protected

    def subset(set)
      Goalkeeper::Set.new.tap do |s|
        set.each {|i| s << i}
      end
    end
  end
end
