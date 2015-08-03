# encoding: utf-8

require 'card_game/value_object'
require 'card_game/rank'
require 'card_game/suit'

module CardGame

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

  # Represents a playing card of rank and suit. This object is deliberately
  # _not_ comparable. Different games defined their own orderings.
  #
  # @attr_reader rank [Rank] Rank of the card.
  # @attr_reader suit [Suit] Suit of the card.
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
        "H" => Suit.hearts,
        "D" => Suit.diamonds,
        "S" => Suit.spades,
        "C" => Suit.clubs,
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
