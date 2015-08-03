require 'card_game/poker/patterns'
require 'card_game/poker/deck'

module CardGame
  # Utility methods for modeling poker.
  class Poker
    # Returns a comparable pattern object describing the hand. Higher hands
    # will sort above lower hands. Never returns +nil+: Hands with nothing
    # interesting return a high card pattern.
    #
    # Standard poker rules are used. Suits are ignored.
    #
    # @return [Comparable]
    # @param hand [Card] hand to classify. Usual length is five,
    #                    though not required.
    def self.classify(hand)
      Patterns::ALL
        .lazy
        .map {|matcher| matcher.apply(hand) }
        .detect(
          ->{ raise "Assertion failed: no matching pattern for #{hand}" }
        ) {|x| x }
    end

    # Creates a deck suitable for poker.
    #
    # @return [Array<Card>]
    def self.deck
      Deck.deck
    end
  end
end
