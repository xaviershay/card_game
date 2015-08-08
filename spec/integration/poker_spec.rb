require 'spec_helper'

require 'csv'

require 'card_game/suit'
require 'card_game/poker'

describe CardGame::Poker do
  it 'recognizes all hands in UCI training set', aggregate_failures: true do
    path = File.expand_path("../data/poker-hand-training-true.data.txt",
                              __FILE__)
    suits = [
      CardGame::Suit.hearts,
      CardGame::Suit.spades,
      CardGame::Suit.diamonds,
      CardGame::Suit.clubs,
    ]

    CSV.foreach(path) do |row|
      expected = row.pop.to_i

      # We don't distinguish between Royal and Straight flushes
      expected = 8 if expected == 9

      cards = row.each.with_index
        .chunk {|_, i| i / 2 }
        .map {|x| x.last.map(&:first) }
        .map {|suit, rank|
          CardGame::Card.new(
            suit: suits[suit.to_i-1],
            rank: CardGame::Ordering::AceLow.ranking[rank.to_i - 1]
          )
        }

      actual = CardGame::Poker.classify(cards).rank
      if actual != expected
        fail "Expected #{cards} pattern to be #{expected}, got #{actual}"
      end
    end
  end
end
