require 'card_game/value_object'

module CardGame
  # A played hand, useful for trick-taking games.
  #
  # @attr_reader [Array<Card>] cards Cards in the trick. First-played is first
  #                                  in the array.
  # @attr_reader [Suit] trump Applicable trump for the trick.  For unsuited
  #                           tricks, use +Suit.none+ for trump.
  class Trick
    include ValueObject

    values do
      attribute :cards, Array[Card]
      attribute :trump, Suit
    end

    def add(card)
      copy(cards: cards + [card])
    end

    def size
      cards.size
    end

    # Create a new trick.
    #
    # @param cards [Array<Card>]
    # @param trump [Suit]
    # @return [Trick]
    def self.build(cards, trump = Suit.none)
      new(cards: cards, trump: trump)
    end
  end
end
