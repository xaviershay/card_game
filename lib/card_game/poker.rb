require 'card_game/value_object'
require 'card_game/ranking'

module CardGame
  class Poker
    class Pattern
      include ValueObject
      include Comparable

      def <=>(other)
        if self.class != other.class
          raise "Cannot compare #{self.inspect} to #{other.inspect}"
        end
        key <=> other.key
      end
    end

    class RankedPattern
      include ValueObject
      include Comparable

      values do
        attribute :pattern
        attribute :rank
      end

      def <=>(other)
        key <=> other.key
      end

      def key
        [rank, pattern]
      end
    end

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

    class HighCard < Pattern
      values do
        attribute :cards
      end

      def key
        cards.map do |card|
          Ranking::AceHigh[card.rank]
        end.sort.reverse
      end

      def self.apply(hand)
        new(cards: hand)
      end
    end

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
        [n, Ranking::AceHigh[rank], HighCard.new(cards: remainder)]
      end

      def self.[](n)
        Matcher.new(n: n)
      end

      class Matcher
        include ValueObject

        values do
          attribute :n
        end

        def apply(hand)
          matches = hand
            .group_by(&:rank)
            .to_a
            .select {|_, cards| cards.size == n }
            .sort_by {|rank, cards| [cards.size, Ranking::AceHigh[rank]] }

          top = matches.pop

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

        new(first: first.rank, second: second.rank, remainder: second.remainder)
      end

      def key
        [
          Ranking::AceHigh[first],
          Ranking::AceHigh[second],
          HighCard.new(cards: remainder),
        ]
      end
    end

    class Straight < Pattern
      values do
        attribute :high, Rank
      end

      def self.apply(hand)
        result = [Ranking::AceHigh, Ranking::AceLow].lazy.map {|ranking|
          ranks = hand.map(&:rank).map {|rank| ranking[rank] }.sort
          min = ranks.first

          expected = (min..ranking.max).take(5)

          if expected.size == 5 && expected.zip(ranks).all? {|x, y| x == y }
            hand.map(&:rank).sort_by {|rank| ranking[rank] }.last
          end
        }.detect {|x| x }

        new(high: result) if result
      end

      def key
        Ranking::AceHigh[high]
      end
    end

    class Flush < HighCard
      def self.apply(hand)
        if hand.size == 5 && hand.map(&:suit).uniq.size == 1
          new(cards: hand)
        end
      end
    end

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

    class StraightFlush < Straight
      def self.apply(hand)
        Flush.apply(hand) && super
      end
    end

    # @private
    PATTERNS = [
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

    def self.classify(hand)
      PATTERNS
        .lazy
        .map {|matcher| matcher.apply(hand) }
        .detect {|x| x }
    end
  end
end
