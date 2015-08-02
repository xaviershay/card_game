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

      alias_method :[], :call
    end

    # @private
    class FromArray < Interface
      include ValueObject

      values do
        attribute :ranking, Array[Rank]
      end

      def call(card)
        ranking.index(card.rank) || raise("Unknown rank: #{rank}")
      end

      def max
        ranking.length - 1
      end

      alias_method :[], :call

      def to_proc
        -> x { call(x) }
      end
    end

    # @private
    AceHigh = FromArray.new(ranking: Numbers + Faces + Ace)

    # @private
    AceLow  = FromArray.new(ranking: Ace + Numbers + Faces)

    # Order aces high, ignoring suit.
    #
    # @return Interface
    # @example
    #     ace_high[Card.from_string("AH")] > ace_high[Card.from_string("KD")]
    #     # => true
    def self.ace_high
      AceHigh
    end

    # Order aces low, ignoring suit.
    #
    # @return Interface
    # @example
    #     ace_low[Card.from_string("AH")] < ace_low[Card.from_string("2D")]
    #     # => true
    def self.ace_low
      AceLow
    end
  end
end
