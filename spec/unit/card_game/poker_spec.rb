require 'spec_helper'

require 'card_game/card'
require 'card_game/poker'

describe CardGame::Poker, aggregate_failures: true do
  def assert_beats(first, second)
    first  = CardGame::Poker.classify(hand(first))
    second = CardGame::Poker.classify(hand(second))

    assert first > second, "#{first} did not rank higher than #{second}"
  end


  def hand(*cards)
    CardGame::Hand.build cards.flatten.shuffle.join(' ')
  end

  describe 'comparing hands' do
    it 'high card wins, ace-high' do
      assert_beats %w(3H), %w(2H)
      assert_beats %w(AH), %w(2H)
      assert_beats %w(AH), %w(KH)
      assert_beats %w(KH), %w(QH)
      assert_beats %w(QH), %w(JH)
      assert_beats %w(JH), %w(10H)
    end

    it 'tie-breaks using subsequent highest cards' do
      assert_beats %w(9S 8S), %w(9D 7C)
      assert_beats %w(9S 8S 7D), %w(9D 8C 6D)
    end

    describe 'single pair' do
      it 'beats high card' do
        assert_beats %w(9S 9D), %w(AD KC)
      end

      it 'high pair wins, ace-high' do
        assert_beats %w(9S 9D), %w(8D 8C)
        assert_beats %w(AS AD), %w(KD KC)
      end

      it 'tie-breaks on high card of remainder' do
        assert_beats %w(9S 9D AD), %w(9C 9H KD)
        assert_beats %w(9S 9D AD KD), %w(9C 9H AH QD)
      end
    end

    describe 'two pair' do
      it 'beats a pair' do
        assert_beats %w(9S 9D 8D 8C), %w(AC AH KH QD)
      end

      it 'high first pair wins' do
        assert_beats %w(AC AH KH KD), %w(9S 9D 8D 8C)
      end

      it 'tie-breaks on second pair' do
        assert_beats %w(AC AH KH KD), %w(AS AD 8D 8C)
      end

      it 'tie-breaks on high card remainder' do
        assert_beats %w(AC AH KH KD QH), %w(AS AD KS KC JH)
      end
    end

    describe 'three of a kind' do
      it 'beats two pair' do
        assert_beats %w(9S 9D 9H), %w(AD AC KD KC)
      end

      it 'high triple wins, ace-high' do
        assert_beats %w(9S 9D 9C), %w(8D 8C 8H)
        assert_beats %w(AS AD AC), %w(KD KC KH)
      end

      it 'tie-breaks on high card of remainder', theoretical: true do
        assert_beats %w(9S 9D 9C AD), %w(9C 9H 9D KD)
        assert_beats %w(9S 9D 9C AD KD), %w(9C 9H 9D AC QC)
      end
    end

    describe 'straight' do
      it 'beats three of a kind' do
        assert_beats %w(2S 3H 4D 5C 6D), %w(9D 9C 9S)
      end

      it 'high card wins' do
        assert_beats %w(2S 3H 4D 5C 6D), %w(AH 2S 3H 4D 5C)
        assert_beats %w(10S JH QD KC AD), %w(9H 10S JH QD KC)
      end
    end

    describe 'flush' do
      it 'beats a straight' do
        assert_beats %w(2S 7S 4S 5S KS), %w(2S 3H 4D 5C 6D)
      end

      it 'tie breaks on high card' do
        assert_beats %w(2S 7S 4S 5S AS), %w(2H 7H 4H 5H KH)
        assert_beats %w(2S 8S 4S 5S AS), %w(2H 7H 4H 5H AH)
      end

      it 'requires 5 cards', theoretical: true do
        assert_beats %w(AS KH), %w(2H 7H 4H 5H)
      end
    end

    describe 'full house' do
      it 'beats a flush' do
        assert_beats %w(2S 2D 2H 3S 3H), %w(2D 3D 4D 5D 7D)
      end

      it 'high card in three wins' do
        assert_beats %w(3S 3D 3H 2S 2H), %w(2D 2H 2C AS AH)
      end

      it 'tie-breaks on pair high card' do
        assert_beats %w(3D 3D 3D AS AH), %w(3S 3S 3S KS KH)
      end
    end

    describe 'four of a kind' do
      it 'beats a full house' do
        assert_beats %w(3S 3D 3H 3C 2H), %w(2D 2C 2H AS AH)
      end

      it 'ties breaks on remainder card', theoretical: true do
        assert_beats %w(3S 3D 3H 3C AH), %w(3S 3D 3H 3C KH)
      end
    end

    describe 'royal flush' do
      it 'beats four of a kind' do
        assert_beats %w(2H 3H 4H 5H 6H), %w(3S 3D 3H 3C AD)
      end

      it 'high card wins' do
        assert_beats %w(2H 3H 4H 5H 6H), %w(AS 2S 3S 4S 5S)
        assert_beats %w(10H JH QH KH AH), %w(9S 10S JS QS KS)
      end
    end
  end

  it '.deck' do
    deck = CardGame::Poker.deck

    assert_equal 52, deck.size
    assert deck.all? {|card| card.is_a?(CardGame::Card) }
    assert deck.none? {|card| card.rank == CardGame::Rank.joker }
  end

  it 'game play through' do
    game = CardGame::Poker.texas_holdem(players: 2, buy_in: 100)
    players = game.state.actors

    game.apply players[1].raise_bet(50)
    game.apply players[0].call_bet

    game.apply players[1].call_bet
    game.apply players[0].call_bet
    game.apply players[1].call_bet
    game.apply players[0].call_bet
    game.apply players[1].call_bet
    game.apply players[0].call_bet
  end
end
