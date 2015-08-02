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
  end
end
