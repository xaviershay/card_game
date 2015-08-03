require 'card_game/core_ext'

describe CardGame::CoreExt, aggregate_failures: true do
  describe 'String' do
    it 'points to the right things' do
      expect("A".hearts).to eq(CardGame::Card.from_string("AH"))
      expect("A".♡).to eq(CardGame::Card.from_string("AH"))
      expect("A".♥︎).to eq(CardGame::Card.from_string("AH"))
      expect("A".♥️︎).to eq(CardGame::Card.from_string("AH"))

      expect("K".diamonds).to eq(CardGame::Card.from_string("KD"))
      expect("K".♢).to eq(CardGame::Card.from_string("KD"))
      expect("K".♦︎).to eq(CardGame::Card.from_string("KD"))
      expect("K".♦️).to eq(CardGame::Card.from_string("KD"))

      expect("Q".clubs).to eq(CardGame::Card.from_string("QC"))
      expect("Q".♧).to eq(CardGame::Card.from_string("QC"))
      expect("Q".♣︎).to eq(CardGame::Card.from_string("QC"))
      expect("Q".♣️).to eq(CardGame::Card.from_string("QC"))

      expect("J".spades).to eq(CardGame::Card.from_string("JS"))
      expect("J".♤).to eq(CardGame::Card.from_string("JS"))
      expect("J".♠︎).to eq(CardGame::Card.from_string("JS"))
      expect("J".♠️︎).to eq(CardGame::Card.from_string("JS"))
    end
  end

  describe 'Integer' do
    it 'points to the right things' do
      expect(3.hearts).to eq(CardGame::Card.from_string("3H"))
      expect(3.♡).to eq(CardGame::Card.from_string("3H"))
      expect(3.♥︎).to eq(CardGame::Card.from_string("3H"))
      expect(3.♥️︎).to eq(CardGame::Card.from_string("3H"))

      expect(5.diamonds).to eq(CardGame::Card.from_string("5D"))
      expect(5.♢).to eq(CardGame::Card.from_string("5D"))
      expect(5.♦︎).to eq(CardGame::Card.from_string("5D"))
      expect(5.♦️).to eq(CardGame::Card.from_string("5D"))

      expect(7.clubs).to eq(CardGame::Card.from_string("7C"))
      expect(7.♧).to eq(CardGame::Card.from_string("7C"))
      expect(7.♣︎).to eq(CardGame::Card.from_string("7C"))
      expect(7.♣️).to eq(CardGame::Card.from_string("7C"))

      expect(10.spades).to eq(CardGame::Card.from_string("10S"))
      expect(10.♤).to eq(CardGame::Card.from_string("10S"))
      expect(10.♠︎).to eq(CardGame::Card.from_string("10S"))
      expect(10.♠️︎).to eq(CardGame::Card.from_string("10S"))
    end
  end
end
