require 'card_game/rank'

module CardGame
  class Poker
    # @private
    module Deck
      def self.ranks
        Rank.numbers + Rank.faces + [Rank.ace]
      end

      def self.deck
        ranks.product(Suit.all - [Suit.none]).map do |rank, suit|
          Card.build(rank, suit)
        end
      end
    end
  end
end
