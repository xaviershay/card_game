require 'card_game/value_object'
require 'card_game/card'

module CardGame
  # Different schemes for ordering cards.
  module Ranking
    # @private
    Numbers = (2..10).map {|n| NumberedRank.new(n: n) }
    # @private
    Faces   = [Jack, Queen, King]
    # @private
    Ace     = [Ace]

    # A function object for a ranking scheme, allowing cards to be sorted
    # according to different criteria (ace-high, ace-low, etc).
    class Interface
      # Returns a consistent token for a +Card+ that will sort with the
      # scheme's properties. Tokens are guaranteed sequential over the full set
      # of cards, but may not be unique, i.e. two cards may produce the same
      # token. The token is not guaranteed stable across versions and should
      # not be persisted.
      #
      # +succ+ is provided on tokens for convenience of identifying straights
      # (+A-2-3-4-5+). It returns the next sequential token in a ranking, but
      # does not map back to a specific +Card+ since multiple cards may have
      # that same next ranking.
      #
      # @return [Comparable, #succ] An opaque sortable token.
      # @param card CardGame::Card
      def call(card)
      end

      # The highest ranking token that could be returned by +call+. Useful when
      # constructing ranges. +succ+ on the token will return +nil+.
      #
      # @return [Comparable, #succ] An opaque sortable token.
      def max
      end

      # Wraps +call+ in a proc. Suitable for use in +map+ and friends.
      #
      # @return [Proc]
      # @example
      #   cards.sort_by(&Ranking.ace_high)
      def to_proc
        -> x { call(x) }
      end

      alias_method :[], :call
    end

    # @private
    class FromArray < Interface
      include ValueObject

      values do
        attribute :ranking, Array[Rank]
      end

      def call(card)
        ranking.index(card.rank) || raise(ArgumentError,
          "Cannot order #{card.rank}. Known ranks: #{ranking}")
      end

      def max
        ranking.length - 1
      end

      alias_method :[], :call
    end

    # @private
    # TODO: Wrap result to provide succ.
    class Composite < Interface
      include ValueObject

      values do
        attribute :children, Array[Interface]
      end

      def call(card)
        children.map do |x|
          begin
            x.call(card)
          rescue ArgumentError => e
            # Assumed that earlier children uniquely sort this card. Instead
            # provide an unrankable token that will raise the exception only if
            # interacted with.
            Unrankable.new(e)
          end
        end
      end
      alias_method :[], :call

      def max
        children.map(&:max)
      end

      # @private
      class Unrankable < BasicObject
        def initialize(ex)
          @ex = ex
        end

        def to_s
          "Unrankable"
        end

        alias_method :inspect, :to_s

        def method_missing(*_)
          ::Kernel.raise @ex
        end
      end
    end

    # @private
    # TODO: Wrap response to provide succ
    class Binary < Interface
      include ValueObject

      values do
        attribute :condition, Proc
      end

      def call(card)
        if condition.call(card)
          1
        else
          0
        end
      end
      alias_method :[], :call

      def max
        1
      end
    end

    # @private
    AceHigh = FromArray.new(ranking: Numbers + Faces + Ace)

    # @private
    AceLow  = FromArray.new(ranking: Ace + Numbers + Faces)

    # Order aces high, ignoring suit.
    #
    # @return [Interface]
    # @example
    #     ace_high[Card.from_string("AH")] > ace_high[Card.from_string("KD")]
    #     # => true
    def self.ace_high
      AceHigh
    end

    # Order aces low, ignoring suit.
    #
    # @return [Interface]
    # @example
    #     ace_low[Card.from_string("AH")] < ace_low[Card.from_string("2D")]
    #     # => true
    def self.ace_low
      AceLow
    end

    # Create a composite ranking from child rankings. Left-most supplied
    # rankings are used first, with subsequent used to break ties.
    #
    # @example
    #     composite = Ranking.composite(
    #       Ranking.suit(Suit.hearts),
    #       Ranking.ace_high,
    #     )
    #     composite[Card.from_string("AS")] > ace_low[Card.from_string("2H")]
    #     # => false
    #     composite[Card.from_string("AS")] > ace_low[Card.from_string("KS")]
    #     # => true
    # @param children [Array<Interface>]
    # @raise [ArgumentError] when no children are provided (+children+ is
    #                        empty).
    # @return [Interface]
    def self.composite(*children)
      if children.empty?
        raise ArgumentError, "Composite ranking must have at least one child."
      end

      Composite.new(children: children)
    end

    # Any card matching the suit is ranked higher than any card of non-matching
    # suits.
    #
    # @param suit [Suit]
    # @return [Interface]
    def self.suit(suit)
      Binary.new(condition: -> card { card.suit == suit })
    end

    # The given card is ranked higher than every other card. Useful for dealing
    # with jokers and other special cards.
    #
    # @param card [Card]
    # @return [Interface]
    def self.match(card)
      Binary.new(condition: -> x { x == card })
    end
  end
end
