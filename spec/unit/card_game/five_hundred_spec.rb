require 'spec_helper'

require 'card_game/five_hundred'

describe CardGame::FiveHundred do
  describe '.winning_card' do
    def assert_winner(winner, hand_string, trump = CardGame::Suit.none)
      actual = CardGame::FiveHundred.winning_card(CardGame::Trick.new(
        cards: CardGame::Hand.build(hand_string),
        trump: trump,
      ))

      assert_equal CardGame::Card.from_string(winner), actual
    end

    it 'picks highest card' do
      assert_winner "AD", "10D 9D AD 2D"
    end

    it 'picks highest card of led suit' do
      assert_winner "KD", "10D JS AC KD"
    end

    it 'picks trump card over high suit' do
      assert_winner "5S", "10D 5S AC KD", CardGame::Suit.spades
    end

    it 'picks left bower over ace' do
      assert_winner "JD", "10D JD 4H KD", CardGame::Suit.hearts
      assert_winner "JH", "10D JH KD KH", CardGame::Suit.diamonds
      assert_winner "JS", "5H JS 5C KS", CardGame::Suit.clubs
      assert_winner "JC", "5S JC KC KS", CardGame::Suit.spades
    end

    it 'picks right bower over left bower' do
      assert_winner "JH", "10S JD JH AH", CardGame::Suit.hearts
      assert_winner "JD", "10S JD JH AD", CardGame::Suit.diamonds
      assert_winner "JC", "5H JS JC KC", CardGame::Suit.clubs
      assert_winner "JS", "5D JC JS QS", CardGame::Suit.spades
    end

    it 'picks joker over right bower' do
      assert_winner "Jk", "Jk JD JH AH", CardGame::Suit.hearts
    end

    it 'picks joker over aces when no trumps' do
      assert_winner "Jk", "Jk AD AS AH"
    end

    it 'ignores bowers when no trumps' do
      assert_winner "QH", "JH QH 10S JD"
    end

    it 'handles extra cards for six player' do
      assert_winner "13H", "13H 12H 11H 10H"
    end
  end

  def assert_deck_with_single_joker(deck, size)
    assert_equal size, deck.size
    assert deck.all? {|card| card.is_a?(CardGame::Card) }
    assert_equal 1, deck.count {|card| card.rank == CardGame::Rank.joker }
  end

  it 'generating a three player deck' do
    deck = CardGame::FiveHundred.deck(players: 3)

    assert_deck_with_single_joker(deck, 33)
  end

  it 'generating a four player deck' do
    deck = CardGame::FiveHundred.deck

    assert_deck_with_single_joker(deck, 43)

    assert deck.none? {|card| card.rank == CardGame::Rank.numbered(2) }
  end

  it 'generating a five player deck' do
    deck = CardGame::FiveHundred.deck(players: 5)

    assert_deck_with_single_joker(deck, 53)
  end

  it 'generating a six player deck' do
    deck = CardGame::FiveHundred.deck(players: 6)

    assert_deck_with_single_joker(deck, 63)
    assert_equal 2, deck.count {|card|
      card.rank == CardGame::Rank.numbered(13)
    }
  end
end
