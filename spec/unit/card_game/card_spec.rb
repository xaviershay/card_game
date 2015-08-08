require 'spec_helper'

require 'card_game/card'

describe CardGame::Card, aggregate_failures: true do
  describe '#to_s' do
    it 'includes suit and rank' do
      assert_equal "A♡ ", CardGame::Card.from_string("AH").to_s
      assert_equal "2♢ ", CardGame::Card.from_string("2D").to_s
      assert_equal "10♧ ", CardGame::Card.from_string("10C").to_s
      assert_equal "J♤ ", CardGame::Card.from_string("JS").to_s
      assert_equal "Jk", CardGame::Card.from_string("Jk").to_s
    end
  end
end
