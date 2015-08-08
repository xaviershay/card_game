require 'spec_helper'

require 'card_game/core_ext'

describe CardGame::CoreExt, aggregate_failures: true do
  describe 'String' do
    it 'points to the right things' do
      expected = CardGame::Card.from_string("AH")
      assert_equal expected, "A".hearts
      assert_equal expected, "A".♡
      assert_equal expected, "A".♥︎
      assert_equal expected, "A".♥️︎

      expected = CardGame::Card.from_string("KD")
      assert_equal expected, "K".diamonds
      assert_equal expected, "K".♢
      assert_equal expected, "K".♦︎
      assert_equal expected, "K".♦️

      expected = CardGame::Card.from_string("QC")
      assert_equal expected, "Q".clubs
      assert_equal expected, "Q".♧
      assert_equal expected, "Q".♣︎
      assert_equal expected, "Q".♣️

      expected = CardGame::Card.from_string("JS")
      assert_equal expected, "J".spades
      assert_equal expected, "J".♤
      assert_equal expected, "J".♠︎
      assert_equal expected, "J".♠️︎
    end
  end

  describe 'Integer' do
    it 'points to the right things' do
      expected = CardGame::Card.from_string("3H")
      assert_equal expected, 3.hearts
      assert_equal expected, 3.♡
      assert_equal expected, 3.♥︎
      assert_equal expected, 3.♥️︎

      expected = CardGame::Card.from_string("5D")
      assert_equal expected, 5.diamonds
      assert_equal expected, 5.♢
      assert_equal expected, 5.♦︎
      assert_equal expected, 5.♦️

      expected = CardGame::Card.from_string("7C")
      assert_equal expected, 7.clubs
      assert_equal expected, 7.♧
      assert_equal expected, 7.♣︎
      assert_equal expected, 7.♣️

      expected = CardGame::Card.from_string("10S")
      assert_equal expected, 10.spades
      assert_equal expected, 10.♤
      assert_equal expected, 10.♠︎
      assert_equal expected, 10.♠️︎
    end
  end
end
