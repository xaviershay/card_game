require 'card_game/value_object'
require 'card_game/card'

module CardGame
  # Different schemes for ordering cards.
  module Ordering
    # Order aces high, ignoring suit.
    #
    # @return [Orderable]
    # @example
    #     ace_high[Card.from_string("AH")] > ace_high[Card.from_string("KD")]
    #     # => true
    def self.ace_high
      AceHigh
    end

    # Order aces low, ignoring suit.
    #
    # @return [Orderable]
    # @example
    #     ace_low[Card.from_string("AH")] < ace_low[Card.from_string("2D")]
    #     # => true
    def self.ace_low
      AceLow
    end

    # Create a composite ordering from child orderings. Left-most supplied
    # orderings are used first, with subsequent used to break ties.
    #
    # @example
    #     composite = Ordering.composite(
    #       Ordering.suit(Suit.hearts),
    #       Ordering.ace_high,
    #     )
    #     composite[Card.from_string("AS")] > ace_low[Card.from_string("2H")]
    #     # => false
    #     composite[Card.from_string("AS")] > ace_low[Card.from_string("KS")]
    #     # => true
    # @param children [Array<Orderable>]
    # @raise [ArgumentError] when no children are provided (+children+ is
    #                        empty).
    # @return [Orderable]
    def self.composite(*children)
      if children.empty?
        raise ArgumentError, "Composite ordering must have at least one child."
      end

      Composite.new(children: children)
    end

    # Wraps the given +Orderable+ so that ranks can be ordered directly. The
    # returned proc takes a +Rank+ and wraps it in an unsuited +Card+ before
    # passing it to the child.
    #
    # @param child [Orderable]
    # @return [Proc]
    def self.rank_only(child)
      -> rank {
        child[Card.unsuited(rank)]
      }
    end

    # Any card matching the suit is ranked higher than any card of non-matching
    # suits.
    #
    # @param suit [Suit]
    # @return [Orderable]
    def self.suit(suit)
      Binary.new(condition: -> card { card.suit == suit })
    end

    # The given card is ranked higher than every other card. Useful for dealing
    # with jokers and other special cards.
    #
    # @param card [Card]
    # @return [Orderable]
    def self.match(card)
      Binary.new(condition: -> x { x == card })
    end

    # A function object for an ordering scheme, allowing cards to be sorted
    # according to different criteria (ace-high, ace-low, etc).
    class Orderable
      # Returns a consistent token for a +Card+ that will sort with the
      # scheme's properties. Tokens may not be unique: two cards may produce
      # the same token. The token is not guaranteed stable across versions and
      # should not be persisted.
      #
      # @return [Comparable] An opaque sortable token.
      # @param card CardGame::Card
      def call(card)
      end

      # Wraps +call+ in a proc. Suitable for use in +map+ and friends.
      #
      # @return [Proc]
      # @example
      #   cards.sort_by(&Ordering.ace_high)
      def to_proc
        -> x { call(x) }
      end

      alias_method :[], :call
    end

    # @private
    class FromArray < Orderable
      include ValueObject

      values do
        attribute :ranking, Array[Rank]
      end

      def call(card)
        token = ranking.index(card.rank) || raise(ArgumentError,
          "Cannot order #{card.rank}. Known ranks: #{ranking}")

        ScopedToken.new(token: token, parent: self)
      end

      alias_method :[], :call
    end

    # @private
    class Composite < Orderable
      include ValueObject

      values do
        attribute :children, Array[Orderable]
      end

      def call(card)
        token = children.map do |x|
          begin
            x.call(card)
          rescue ArgumentError => e
            # Assumed that earlier children uniquely sort this card. Instead
            # provide an unrankable token that will raise the exception only if
            # interacted with.
            Unrankable.new(e)
          end
        end
        ScopedToken.new(token: token, parent: self)
      end
      alias_method :[], :call

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
    class Binary < Orderable
      include ValueObject

      values do
        attribute :condition, Proc
      end

      def call(card)
        ScopedToken.new(token: condition.call(card) ? 1 : 0, parent: self)
      end
      alias_method :[], :call
    end

    # @private
    AceHigh = FromArray.new(ranking: Rank.numbers + Rank.faces + [Rank.ace])

    # @private
    AceLow  = FromArray.new(ranking: [Rank.ace] + Rank.numbers + Rank.faces)

    # @private
    class ScopedToken
      include ValueObject
      include Comparable

      values do
        # Token should implement <=>. You'd think that means it is Comparable,
        # but Array does not implement that interface.
        attribute :token
        # Parent can be any object that implements equality.
        attribute :parent
      end

      def <=>(other)
        unless self.class === other
          raise "Cannot compare #{self.class} with #{other.class}"
        end

        unless parent == other.parent
          raise "Cannot compare tokens from different orderings: %s and %s" % [
            parent,
            other.parent
          ]
        end

        token <=> other.token
      end
    end

  end
end
