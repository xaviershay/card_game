require 'spec_helper'

require 'card_game/suit'

describe CardGame::Suit do
  describe 'aliases' do
    it 'points to the right things' do
      assert_equal CardGame::Suit.hearts, CardGame::Suit.♡
      assert_equal CardGame::Suit.hearts, CardGame::Suit.♥︎
      assert_equal CardGame::Suit.hearts, CardGame::Suit.♥️︎
      assert_equal CardGame::Suit.diamonds, CardGame::Suit.♢
      assert_equal CardGame::Suit.diamonds, CardGame::Suit.♦︎
      assert_equal CardGame::Suit.diamonds, CardGame::Suit.♦️
      assert_equal CardGame::Suit.clubs, CardGame::Suit.♧
      assert_equal CardGame::Suit.clubs, CardGame::Suit.♣︎
      assert_equal CardGame::Suit.clubs, CardGame::Suit.♣️
      assert_equal CardGame::Suit.spades, CardGame::Suit.♤
      assert_equal CardGame::Suit.spades, CardGame::Suit.♠︎
      assert_equal CardGame::Suit.spades, CardGame::Suit.♠️︎
    end
  end
end
