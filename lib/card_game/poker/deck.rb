require 'card_game/rank'

module CardGame
  class Poker
    # @private
    module Deck
      def self.ranks
        Rank.numbers + Rank.faces + [Rank.ace]
      end
    end
  end
end
