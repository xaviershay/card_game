require 'virtus'

require 'card_game/card'

module CardGame
  module Ranking
    Numbers = (2..10).map {|n| NumberedRank.new(n: n) }
    Faces   = [Jack, Queen, King]
    Ace     = [Ace]

    class FromArray
      include Virtus.value_object

      values do
        attribute :ranking, Array[Rank]
      end

      def [](rank)
        ranking.index(rank) || raise("Unknown rank: #{rank}")
      end

      def max
        ranking.length - 1
      end
    end

    AceHigh = FromArray.new(ranking: Numbers + Faces + Ace)
    AceLow  = FromArray.new(ranking: Ace + Numbers + Faces)
  end
end
