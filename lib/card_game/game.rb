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

    # Abstract parent class for game phases. Phases need not subclass, so long
    # as they provide the same class-level interface.
    #
    # See {Game} for an overview of how phases interact with other game
    # objects.
    #
    # @abstract Subclasses likely want to override at least {#enter} or
    #   {#apply}.
    class Phase
      # Called each time the phase is transitioned into. Wraps the state in a
      # new instance and calls {#enter}.
      #
      # @param state [Object]
      # @return [Object] New state. May be the same as old.
      def self.enter(state); new(state).enter end

      # Called each time the phase is transitioned out of. Wraps the state in a
      # new instance and calls {#exit}.
      #
      # @param state [Object]
      # @return [Object] New state. May be the same as old.
      def self.exit(state); new(state).exit end

      # Called when this phase is current. The phase is expected to return a
      # new state by applying the action to the provided state. Wraps the state
      # in a new instance and calls {#apply}.
      #
      # @param state [Object]
      # @param action [Action]
      # @return [Object] New state from applying the action. Must not be the
      #                  same as the old state.
      def self.apply(state, action); new(state).apply(action) end

      # Called when this phase is current and the state has changed. Should
      # return +nil+ to remain active, or another {Phase} to transition to it.
      # Wraps the state in a new instance and calls {#transition}.
      #
      # @param state [Object]
      # @return [Phase]
      def self.transition(state); new(state).transition end

      # @!group Protected Instance Methods

      # Returns the state unchanged. Subclasses may override this behaviour.
      #
      # @see .enter
      # @return [Object] New state. May be the same as old.
      def enter; state end

      # Returns the state unchanged. Subclasses may override this behaviour.
      #
      # @see .exit
      # @return [Object] New state. May be the same as old.
      def exit; state end

      # Always raises. Since actions must transform the state, no default
      # behaviour is reasonable. Subclasses do not need to override if they
      # immediately transition to a new phase (i.e. the {#transition} method
      # never returns +nil+), since this will not leave an opportunity for an
      # action to be applied.
      #
      # @see .apply
      # @param action [Action]
      # @return [Object] New state from applying the action. Must not be the
      #                  same as the old state.
      def apply(action)
        # TODO: How to avoid calls to super, so can raise here.
#         raise NotImplementedError
      end

      # Returns +nil+, indicating that this phase should remain active.
      # Subclasses may override this behaviour.
      #
      # Returning +self.class+ is treated as changing to a new phase: it will
      # cause {.exit} and {.enter} to be called.
      #
      # @see .transition
      # @return [Phase]
      def transition; end

      # @!endgroup Protected Instance Methods

      protected

      attr_reader :state

      def initialize(state)
        @state = state
      end

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
