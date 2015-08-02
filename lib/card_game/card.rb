# encoding: utf-8

require 'virtus'

module CardGame
  class Rank
    include Virtus.value_object
  end

  class Hand
    def self.build(string)
      string.split(/\s+/).map(&Card.method(:from_string))
    end
  end

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

  class NamedRank < Rank
    values do
      attribute :name, String
    end

    def to_s
      name[0]
    end

    def inspect
      to_s
    end
  end

  Jack  = NamedRank.new(name: 'Jack')
  Queen = NamedRank.new(name: 'Queen')
  King  = NamedRank.new(name: 'King')
  Ace   = NamedRank.new(name: 'Ace')

  class Suit
    include Virtus.value_object

    attribute :symbol, String

    def to_s
      symbol + " "
    end

    def inspect
      to_s
    end
  end

  Spades   = Suit.new(symbol: "♤")
  Hearts   = Suit.new(symbol: "♡")
  Diamonds = Suit.new(symbol: "♢")
  Clubs    = Suit.new(symbol: "♧")

  class Card
    include Virtus.value_object

    values do
      attribute :rank, Rank
      attribute :suit, Suit
    end

    def to_s
      rank.to_s + suit.to_s
    end

    def inspect
      to_s
    end

    def self.from_string(value)
      short_suit = value[-1]
      suit = {
        "H" => Hearts,
        "D" => Diamonds,
        "S" => Spades,
        "C" => Clubs,
      }.fetch(short_suit)

      rank = {
        'A' => Ace,
        'K' => King,
        'Q' => Queen,
        'J' => Jack,
      }.fetch(value[0]) { NumberedRank.new(n: value[0..-2].to_i) }

      new(suit: suit, rank: rank)
    end
  end

end
