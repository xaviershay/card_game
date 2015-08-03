# encoding: utf-8

require 'card_game/value_object'
require 'card_game/rank'

module CardGame
  class Color
    include ValueObject

    attribute :name, String

    Red   = new(name: "red")
    Black = new(name: "black")
    None  = new(name: "none")

    def self.red; Red end
    def self.black; Black end
    def self.none; None end
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

  # Suit of a card, such as hearts or diamonds.  This is a very dumb object,
  # just providing basic equality and inspection.
  class Suit
    include ValueObject

    attribute :symbol, String
    attribute :color, Color

    # Short string representation of the suit.
    def to_s
      symbol
    end

    alias_method :inspect, :to_s

    def self.all
      AllSuits
    end
  end

  # @private
  Hearts   = Suit.new(symbol: "♡ ", color: Color.red)
  # @private
  Diamonds = Suit.new(symbol: "♢ ", color: Color.red)
  # @private
  Clubs    = Suit.new(symbol: "♧ ", color: Color.black)
  # @private
  Spades   = Suit.new(symbol: "♤ ", color: Color.black)
  # @private
  NoSuit   = Suit.new(symbol: "", color: Color.none)

  AllSuits = [Hearts, Diamonds, Clubs, Spades, NoSuit]

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
      return new(suit: Suit.none, rank: Rank.joker) if value == "Jk"

      short_suit = value[-1]
      suit = {
        "H" => Hearts,
        "D" => Diamonds,
        "S" => Spades,
        "C" => Clubs,
      }.fetch(short_suit)

      rank = {
        'A' => Rank.ace,
        'K' => Rank.king,
        'Q' => Rank.queen,
        'J' => Rank.jack,
      }.fetch(value[0]) { Rank.numbered(value[0..-2].to_i) }

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
