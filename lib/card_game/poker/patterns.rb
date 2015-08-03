require 'card_game/value_object'
require 'card_game/ordering'

module CardGame
  class Poker
    # @private
    module Patterns
      # @private
      class Pattern
        include ValueObject
        include Comparable

        def <=>(other)
          if self.class != other.class
            raise "Cannot compare #{self.inspect} to #{other.inspect}"
          end
          key <=> other.key
        end

        # @api private
        # @see CardGame::Poker.classify
        def initialize(*args)
          super
        end
      end

      # @private
      class RankedPattern < Patterns::Pattern
        values do
          attribute :pattern
          attribute :rank
        end

        def <=>(other)
          super
        end

        def initialize(*_)
          super
        end

        # @private
        def key
          [rank, pattern]
        end
      end

      # @private
      class RankedPatternMatcher
        include ValueObject
        include Comparable

        values do
          attribute :pattern_type
          attribute :rank
        end

        def apply(*args)
          result = pattern_type.apply(*args)
          if result
            RankedPattern.new(pattern: result, rank: rank)
          end
        end
      end

      # @private
      class HighCard < Pattern
        values do
          attribute :cards
        end

        def key
          cards.map(&Ordering.ace_high).sort.reverse
        end

        def self.apply(hand)
          new(cards: hand)
        end
      end

      # @private
      class OfAKind < Pattern
        values do
          attribute :rank
          attribute :n
          attribute :remainder
        end

        def <=>(other)
          result = super

          # This assertion is needed since we re-use this same class for pair,
          # three, and four of a kind. They should be compared by RankedPattern
          # before falling through to here.
          if n != other.n
            raise "Cannot compare kinds of different order (#{n} != #{other.n})"
          end

          result
        end

        def key
          [
            n,
            Ordering.ace_high[Card.unsuited(rank)],
            HighCard.new(cards: remainder)
          ]
        end

        def self.[](n)
          Matcher.new(n: n)
        end

        # @private
        class Matcher
          include ValueObject

          values do
            attribute :n
          end

          def apply(hand)
            top = hand
              .group_by(&:rank)
              .to_a
              .select {|_, cards| cards.size == n }
              .sort_by {|rank, cards|
                [cards.size, Ordering.ace_high[Card.unsuited(rank)]]
              }
              .pop

            if top && top[1].size >= 2
              OfAKind.new(
                rank:      top[0],
                n:         top[1].size,
                remainder: hand - top[1],
              )
            end
          end
        end
      end

      # @private
      class TwoPair < Pattern
        values do
          attribute :first
          attribute :second
          attribute :remainder, Array[Card]
        end

        def self.apply(hand)
          first = OfAKind[2].apply(hand)
          return unless first

          second = OfAKind[2].apply(first.remainder)
          return unless second

          new(
            first:     first.rank,
            second:    second.rank,
            remainder: second.remainder
          )
        end

        def key
          [
            Ordering.ace_high[Card.unsuited(first)],
            Ordering.ace_high[Card.unsuited(second)],
            HighCard.new(cards: remainder),
          ]
        end
      end

      # @private
      class Straight < Pattern
        values do
          attribute :high, Rank
        end

        def self.apply(hand)
          result = [Ordering.ace_high, Ordering.ace_low].lazy.map {|ranking|
            ranks = hand.map(&ranking).sort
            min = ranks.first

            expected = (min..ranking.max).take(5)

            if expected.size == 5 && expected.zip(ranks).all? {|x, y| x == y }
              hand.sort_by(&ranking).last
            end
          }.detect {|x| x }

          new(high: result.rank) if result
        end

        def key
          Ordering.ace_high[Card.unsuited(high)]
        end
      end

      # @private
      class Flush < HighCard
        def self.apply(hand)
          if hand.size == 5 && hand.map(&:suit).uniq.size == 1
            new(cards: hand)
          end
        end
      end

      # @private
      class FullHouse < Pattern
        values do
          attribute :pattern
        end

        def self.apply(hand)
          three = OfAKind[3].apply(hand)
          return unless three

          two = OfAKind[2].apply(three.remainder)
          return unless two

          new(pattern: three)
        end

        def key
          pattern
        end
      end

      # @private
      class StraightFlush < Straight
        def self.apply(hand)
          Flush.apply(hand) && super
        end
      end

      # @private
      ALL = [
        StraightFlush,
        OfAKind[4],
        FullHouse,
        Flush,
        Straight,
        OfAKind[3],
        TwoPair,
        OfAKind[2],
        HighCard,
      ].reverse.map.with_index {|x, i|
        RankedPatternMatcher.new(pattern_type: x, rank: i)
      }.reverse
    end
  end
end

