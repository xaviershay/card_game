module CardGame
  # Life-cycle manager for a game of cards. It isn't particular about which
  # game. Given an initial *state* and *phase*, it provides a workflow for
  # modify the state via *actions*. Virtually all card games can be modeled
  # with this abstraction. See specific implementations (Poker, Five Hundred)
  # for examples.
  class Game
    # Raised when an invalid game state is encountered, either when trying to
    # read part of the state that is not available, or when transitioning the
    # state.
    class StateError < RuntimeError; end

    # Current game state. At its simplest this could be a +Hash+, but most
    # games will want to implement a richer state object providing common
    # transformations.
    #
    # @attribute [r] state
    # @return [Object]
    attr_reader :state

    # Current game phase. Determines what actions are allowed.
    #
    # @return [Phase]
    # @attribute [r] phase
    attr_reader :phase

    def initialize(phase, state)
      @phase = phase
      @state = @phase.enter(state)

      transition
    end

    # Apply the action to the state using the current phase to produce a new
    # state, then transition to a new phase if appropriate.
    #
    # All legal actions must cause the new state to differ from the old one.
    # This restriction is precautionary: a use case may be found where this
    # should be allowed, but I haven't found it yet.
    #
    # @raise [StateError] if the action was not valid for the current state.
    # @raise [StateError] if applying the action did not cause the state to
    #                     change.
    def apply(action)
      self.state = phase.apply(state, action)

      transition
    end

    protected

    attr_writer :state, :phase

    def transition
      new_phase = phase.transition(state)

      if new_phase
        self.state = phase.exit(state)
        self.phase = new_phase
        self.state = phase.enter(state)

        transition
      end
    end

    class Phase
      attr_reader :state

      def self.enter(state); new(state).enter end
      def self.exit(state); new(state).exit end
      def self.apply(state, action); new(state).apply(action) end
      def self.transition(state); new(state).transition end

      def initialize(state)
        @state = state
      end

      def enter; state end
      def exit; state end
      def apply(action); state end
      def transition; end
    end

    class Player
      include ValueObject

      values do
        attribute :position, Integer
      end

      def name
        "Player"
      end

      def to_s
        "<#{name} %i>" % position
      end
      alias_method :inspect, :to_s

      def pretty_print(pp)
        pp.text(to_s)
      end
    end

    class Action
      include ValueObject

      values do
        attribute :actor
      end

      def self.build(actor)
        new(actor: actor)
      end
    end
  end
end
