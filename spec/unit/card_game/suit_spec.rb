describe CardGame::Suit, aggregate_failures: true do
  describe 'aliases' do
    it 'points to the right things' do
      expect(CardGame::Suit.♡).to eq(CardGame::Suit.hearts)
      expect(CardGame::Suit.♥︎).to eq(CardGame::Suit.hearts)
      expect(CardGame::Suit.♥️︎).to eq(CardGame::Suit.hearts)

      expect(CardGame::Suit.♢).to eq(CardGame::Suit.diamonds)
      expect(CardGame::Suit.♦︎).to eq(CardGame::Suit.diamonds)
      expect(CardGame::Suit.♦️).to eq(CardGame::Suit.diamonds)

      expect(CardGame::Suit.♧).to eq(CardGame::Suit.clubs)
      expect(CardGame::Suit.♣︎).to eq(CardGame::Suit.clubs)
      expect(CardGame::Suit.♣️).to eq(CardGame::Suit.clubs)

      expect(CardGame::Suit.♤).to eq(CardGame::Suit.spades)
      expect(CardGame::Suit.♠︎).to eq(CardGame::Suit.spades)
      expect(CardGame::Suit.♠️︎).to eq(CardGame::Suit.spades)
    end
  end
end
