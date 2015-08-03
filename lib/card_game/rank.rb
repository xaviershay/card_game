module CardGame
  # The rank of a card, either the number or face name (Jack, Queen, etc...).
  # This is a very dumb object, just providing basic equality and inspection.
  class Rank
    include ValueObject

    # Short string representation of the rank.
    def to_s
      super
    end

    def self.numbered(n); Private::NumberedRank.new(n: n) end

    def self.jack;  Private::NamedRank.new(name: 'Jack') end
    def self.queen; Private::NamedRank.new(name: 'Queen') end
    def self.king;  Private::NamedRank.new(name: 'King') end
    def self.ace;   Private::NamedRank.new(name: 'Ace') end
    def self.joker; Private::NamedRank.new(name: 'Joker', short: 'Jk') end

    def self.all
      numbers + faces + [ace, joker]
    end

    def self.numbers
      (2..10).map {|n| numbered(n) }
    end

    def self.faces
      [jack, queen, king]
    end

    private

    def initialize(*args)
      super
    end
  end

  # @private
  module Rank::Private
    # @private
    class NumberedRank < Rank
      values do
        attribute :n, Integer
      end

      def to_s
        n.to_s
      end

      def inspect
        "R#{n}"
      end
    end

    # @private
    class NamedRank < Rank
      values do
        attribute :name, String
        attribute :short
      end

      def to_s
        short || name[0]
      end

      alias_method :inspect, :to_s
    end
  end
end
