# encoding: utf-8

require 'card_game/value_object'

module CardGame
  # The rank of a card, either the number or face name (Jack, Queen, etc...).
  # This is a very dumb object, just providing basic equality and inspection.
  class Rank
    include ValueObject

    # Short string representation of the rank.
    def to_s
      super
    end
  end

  # Represents a hand of multiple cards. Current this is actually represented
  # as an array.
  class Hand
    # Create an array of cards uing a shorthand string syntax.
    #
    # @see CardGame::Card.from_string
    # @return [CardGame::Card]
    # @example
    #     CardGame::Hand.build("10H JC QD KS AD")
    def self.build(string)
      string.split(/\s+/).map(&Card.method(:from_string))
    end
  end

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
    end

    def to_s
      name[0]
    end

    alias_method :to_a, :inspect
  end

  # @private
  Jack  = NamedRank.new(name: 'Jack')
  # @private
  Queen = NamedRank.new(name: 'Queen')
  # @private
  King  = NamedRank.new(name: 'King')
  # @private
  Ace   = NamedRank.new(name: 'Ace')

  # Suit of a card, such as hearts or diamonds.  This is a very dumb object,
  # just providing basic equality and inspection.
  class Suit
    include ValueObject

    attribute :symbol, String

    # Short string representation of the suit.
    def to_s
      symbol + " "
    end

    alias_method :inspect, :to_s
  end

  # @private
  Spades   = Suit.new(symbol: "♤")
  # @private
  Hearts   = Suit.new(symbol: "♡")
  # @private
  Diamonds = Suit.new(symbol: "♢")
  # @private
  Clubs    = Suit.new(symbol: "♧")
  # @private
  NoSuit   = Suit.new(symbol: "")

  # @return Suit
  def Suit.spades; Spades end
  # @return Suit
  def Suit.hearts; Hearts end
  # @return Suit
  def Suit.diamonds; Diamonds end
  # @return Suit
  def Suit.clubs; Clubs end
  # @return Suit
  def Suit.none; NoSuit end

  # Represents a playing card of rank and suit. This object is deliberately
  # _not_ comparable. Different games defined their own orderings.
  #
  # @see CardGame::Ranking
  class Card
    include ValueObject

    values do
      attribute :rank, Rank
      attribute :suit, Suit
    end

    # String representation of card. May include unicode suit symbol.
    #
    # @return String
    def to_s
      rank.to_s + suit.to_s
    end

    alias_method :inspect, :to_s

    # Construct a card from a shorthand string syntax. Suits are represented by
    # the first letter of their name (+H+ for hearts), as are ranks although
    # numbers are numeric.
    #
    # @return CardGame::Card
    # @example
    #   Card.from_string("AD")  # Ace of diamonds
    #   Card.from_string("10H") # Ten of hearts
    #   Card.from_string("KS")  # King of spades
    #   Card.from_string("2C")  # Two of clubs
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

    # Construct a card with no suit.
    #
    # @param rank [Rank]
    # @return Card
    def self.unsuited(rank)
      new(rank: rank, suit: Suit.none)
    end
  end

end
