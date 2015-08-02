require 'card_game/card'
require 'card_game/ranking'
require 'card_game/trick'

module CardGame
  # Utility methods for modeling five hundred.
  class FiveHundred
    # @private
    OPPOSITES = {
      Suit.hearts   => Suit.diamonds,
      Suit.diamonds => Suit.hearts,
      Suit.clubs    => Suit.spades,
      Suit.spades   => Suit.clubs,
    }

    # Returns the winning card of a given trick.
    #
    # @param trick [Trick]
    # @return [Card]
    def self.winning_card(trick)
      led = trick.cards.first

      raise(ArgumentError, "Trick must contain at least one card") unless led

      opposite = OPPOSITES.fetch(trick.trump) { Suit.none }
      left_bower  = Card.new(rank: Jack, suit: opposite)
      right_bower = Card.new(rank: Jack, suit: trick.trump)
      joker       = Card.new(rank: Joker, suit: Suit.none)

      trick.cards.sort_by(&Ranking.composite(
        Ranking.match(joker),
        Ranking.match(right_bower),
        Ranking.match(left_bower),
        Ranking.suit(trick.trump),
        Ranking.suit(led.suit),
        Ranking.ace_high,
      )).last
    end
  end
end
