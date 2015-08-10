module CardGame
  class Game
    class StateError < RuntimeError; end

    attr_accessor :state, :phase

    def initialize(phase, state)
      @phase = phase
      @state = @phase.enter(state)

      transition
    end

    def apply(action)
      self.state = phase.apply(state, action)

      transition
    end

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
