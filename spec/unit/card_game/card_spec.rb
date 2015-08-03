require 'spec_helper'

require 'card_game/card'

describe CardGame::Card, aggregate_failures: true do
  describe '#to_s' do
    it 'includes suit and rank' do
      expect(CardGame::Card.from_string("AH").to_s).to eq("A♡ ")
      expect(CardGame::Card.from_string("2D").to_s).to eq("2♢ ")
      expect(CardGame::Card.from_string("10C").to_s).to eq("10♧ ")
      expect(CardGame::Card.from_string("JS").to_s).to eq("J♤ ")
      expect(CardGame::Card.from_string("Jk").to_s).to eq("Jk")
    end
  end
end
