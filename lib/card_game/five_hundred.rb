require 'card_game/card'
require 'card_game/ordering'
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

    # Returns the winning card of a given trick, accounting for trumps, bowers,
    # and the Joker.
    #
    # @param trick [Trick]
    # @return [Card]
    def self.winning_card(trick)
      led = trick.cards.first

      raise(ArgumentError, "Trick must contain at least one card") unless led

      opposite = OPPOSITES.fetch(trick.trump) { Suit.none }
      left_bower  = Card.new(rank: Rank.jack, suit: opposite)
      right_bower = Card.new(rank: Rank.jack, suit: trick.trump)
      joker       = Card.new(rank: Rank.joker, suit: Suit.none)

      trick.cards.sort_by(&Ordering.composite(
        Ordering.match(joker),
        Ordering.match(right_bower),
        Ordering.match(left_bower),
        Ordering.suit(trick.trump),
        Ordering.suit(led.suit),
        Ordering.by_rank(ALL_RANKS),
      )).last
    end

    # Creates a deck suitable for Five Hundred.
    #
    # @param players [Integer] The number of players. Must be between 3 and 6.
    # @return [Array<Card>]
    def self.deck(players: 4)
      joker = [Card.unsuited(Rank.joker)]

      ranks_for_colors = DECK_SPECIFICATION.fetch(players) {
        raise ArgumentError,
          "Only 3 to 6 players are supported, not #{players}"
      }

      joker + ALL_RANKS.product(Suit.all)
        .map {|rank, suit| Card.build(rank, suit) }
        .select {|card|
          ranks_for_colors.fetch(card.suit.color).include?(card.rank)
        }
    end

    make_ranks = -> r {
      r.map(&Rank.method(:numbered)) + Rank.faces + [Rank.ace]
    }

    # Deck specifications for different numbers of players.
    #
    # @private
    DECK_SPECIFICATION = {
      3 => {
        Color.red   => make_ranks.(7..10),
        Color.black => make_ranks.(7..10),
      },
      4 => {
        Color.red   => make_ranks.(4..10),
        Color.black => make_ranks.(5..10),
      },
      5 => {
        Color.red   => make_ranks.(2..10),
        Color.black => make_ranks.(2..10),
      },
      6 => {
        Color.red   => make_ranks.(2..13),
        Color.black => make_ranks.(2..12),
      }
    }

    # All known ranks.
    #
    # @private
    ALL_RANKS = DECK_SPECIFICATION.fetch(6)[Color.red]
  end
end
