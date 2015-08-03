require 'spec_helper'

require 'card_game/ordering'

describe CardGame::Ordering do
  describe '.suit' do
    it 'responds to #succ correctly' do
      offsuit = CardGame::Card.from_string("AD")
      onsuit  = CardGame::Card.from_string("AH")
      ordering = CardGame::Ordering.suit(onsuit.suit)

      token = ordering.call(offsuit)
      token = token.succ
      expect(token).to eq(ordering.call(onsuit))
      expect(token.succ).to eq(nil)
    end
  end
end
