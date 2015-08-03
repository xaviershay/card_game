require 'spec_helper'

require 'card_game/ordering'

describe CardGame::Ordering do
  let(:joker) { CardGame::Card.from_string("Jk") }
  let(:ace) { CardGame::Card.from_string("AD") }

  describe '.ace_high and .ace_low' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.ace_high,
        CardGame::Ordering.ace_low,
      ]

      expect {
        orderings[0][ace] <=> orderings[1][ace]
      }.to raise_error(/different orderings/)
    end

    it 'does allow comparisons between different ace_high calls' do
      orderings = [
        CardGame::Ordering.ace_high,
        CardGame::Ordering.ace_high,
      ]

      expect(orderings[0][ace] <=> orderings[1][ace]).to eq(0)
    end

    it 'does allow comparisons between different ace_low calls' do
      orderings = [
        CardGame::Ordering.ace_low,
        CardGame::Ordering.ace_low,
      ]

      expect(orderings[0][ace] <=> orderings[1][ace]).to eq(0)
    end
  end

  describe '.suit' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.suit(joker.suit),
        CardGame::Ordering.suit(ace.suit),
      ]

      expect {
        orderings[0][joker] <=> orderings[1][joker]
      }.to raise_error(/different orderings/)
    end
  end

  describe '.match' do
    it 'does not allow comparisons between different orderings' do
      orderings = [
        CardGame::Ordering.match(joker),
        CardGame::Ordering.match(ace),
      ]

      expect {
        orderings[0][joker] <=> orderings[1][joker]
      }.to raise_error(/different orderings/)
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

      expect {
        orderings[0][joker] <=> orderings[1][joker]
      }.to raise_error(/different orderings/)
    end
  end
end
