require 'spec_helper'

require 'card_game/ordering'

describe CardGame::Ordering do
  let(:joker) { CardGame::Card.from_string("Jk") }
  let(:ace) { CardGame::Card.from_string("AD") }

  def assert_unorderable(orderings, card)
    begin
      orderings[0][card] <=> orderings[1][card]
      fail
    rescue => e
      assert_include "different orderings", e.message
    end
  end

  describe '.ace_high and .ace_low' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.ace_high,
        CardGame::Ordering.ace_low,
      ]

      assert_unorderable orderings, ace
    end

    it 'does allow comparisons between different ace_high calls' do
      orderings = [
        CardGame::Ordering.ace_high,
        CardGame::Ordering.ace_high,
      ]

      assert_equal 0, orderings[0][ace] <=> orderings[1][ace]
    end

    it 'does allow comparisons between different ace_low calls' do
      orderings = [
        CardGame::Ordering.ace_low,
        CardGame::Ordering.ace_low,
      ]

      assert_equal 0, orderings[0][ace] <=> orderings[1][ace]
    end
  end

  describe '.suit' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.suit(joker.suit),
        CardGame::Ordering.suit(ace.suit),
      ]

      assert_unorderable orderings, joker
    end
  end

  describe '.match' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.match(joker),
        CardGame::Ordering.match(ace),
      ]

      assert_unorderable orderings, joker
    end
  end

  describe '.composite' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.composite(
          CardGame::Ordering.suit(CardGame::Suit.hearts)
        ),
        CardGame::Ordering.composite(
          CardGame::Ordering.suit(CardGame::Suit.diamonds)
        ),
      ]

      assert_unorderable orderings, joker
    end
  end
end
