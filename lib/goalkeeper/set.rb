module Goalkeeper
  # Set is an Array of Goals to simplify tracking multiple goals.
  # Since Set is an array, you have all Array methods available.
  #
  # Create a new set
  #   myset = Goalkeeper::Set.new
  #
  # Add Goals you want to check for completion
  #   myset.add("job1").add("job2")
  #   myset.size
  #   #=> 2
  #
  # Check if all the goals are completed
  #   myset.met?
  #   #=> false
  #
  # Get the unmet Goals
  #   myset.unmet
  #   #=> [...]
  #
  # Get the met Goals
  #   myset.met
  #   #=> [...]
  #
  # Iterate all Goals
  #   myset.each {|goal| ...}
  #   myset.map  {|goal| ...}
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

    # nil if this set is not met?
    # otherwise returns the met_at Time for the last met goal
    def met_at
      if met?
        self.map(&:met_at).sort.last
      else
        nil
      end
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
