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

  it 'game play through' do
    game = CardGame::FiveHundred.play(players: 4)

    players = game.state.players
    hand = -> player { game.state.hands.fetch(player) }

    assert players.all? {|player|
      hand.(player).size == 10
    }

    game.apply players[0].bid(6, CardGame::Suit.hearts)
    game.apply players[1].pass
    game.apply players[2].bid(7, CardGame::Suit.hearts)
    game.apply players[3].pass
    game.apply players[0].pass
    game.apply players[1].pass

    assert_equal players[2], game.state.priority
    assert_equal 13, game.state.priority_hand.size

    game.apply players[2].kitty(hand.(players[2]).take(3))

    (0..9).each do
      i = players.index(game.state.priority)
      game.apply players[(i+0) % 4].play(hand.(players[(i+0) % 4])[0])
      game.apply players[(i+1) % 4].play(hand.(players[(i+1) % 4])[0])
      game.apply players[(i+2) % 4].play(hand.(players[(i+2) % 4])[0])
      game.apply players[(i+3) % 4].play(hand.(players[(i+3) % 4])[0])
    end

    assert game.state.scores.values.reduce(:+) != 0
    assert_equal CardGame::FiveHundred::Phase::Bidding, game.phase
  end

  describe 'state' do
    def state(players)
      CardGame::FiveHundred::State.initial(players)
    end

    def fake_deck
      CardGame::FiveHundred.deck(players: 4)
    end

    describe 'advance' do
      it '#passes priority to next player' do
        s = state(%i(a b))
          .give_priority(:a)

        assert_equal :b, (s = s.advance).priority
        assert_equal :a, (s = s.advance).priority
      end
    end

    describe '#advance_dealer' do
      it 'passes deal to next player' do
        s = state(%i(a b))
          .give_deal(:a)

        assert_equal :b, (s = s.advance_dealer).dealer
        assert_equal :a, (s = s.advance_dealer).dealer
      end
    end

    describe '#adjust_score' do
      it 'adds points to a team' do
        s = state(%i(a b c))
          .adjust_score(%i(a b), 100)

        assert_equal({a: 100, b: 100, c: 0}, s.scores)

        s = s.adjust_score(%i(a c), -30)

        assert_equal({a: 70, b: 100, c: -30}, s.scores)
      end
    end

    describe '#team_for' do
      it 'selects opposite player in 4-handed' do
        s = state(%i(a b c d))

        assert_equal [:a, :c], s.team_for(:a).to_a.sort
        assert_equal [:a, :c], s.team_for(:c).to_a.sort
        assert_equal [:b, :d], s.team_for(:b).to_a.sort
        assert_equal [:b, :d], s.team_for(:d).to_a.sort
      end
    end

    describe '#won_trick' do
      it 'increments trick count' do
        s = state(%i(a b))

        s = s.won_trick(:a)
        s = s.won_trick(:a)
        s = s.won_trick(:b)

        assert_equal({a: 2, b: 1}, s.tricks)
      end
    end

    describe '#clear_tricks' do
      it 'resets trick counts to 0' do
        s = state(%i(a b))
          .won_trick(:a)
          .clear_tricks

        assert_equal({a: 0, b: 0}, s.tricks)
      end

      it 'deletes the current trick' do
        s = state(%i(a b))
          .new_trick
          .clear_tricks

        begin
          s.trick
          fail "did not raise"
        rescue CG::Game::StateError => e
          assert_include "trick", e.message
        end
      end
    end

    describe '#deal for 4 people' do
      def dealt_state
        @dealt_state ||= state(%i(a b c d))
          .deal(fake_deck)
      end

      it 'deals 10 cards to each person' do
        assert_equal [10, 10, 10, 10], dealt_state.hands.values.map(&:size)
      end

      it 'deals 3 cards to kitty' do
        assert_equal 3, dealt_state.kitty.size
      end

      it 'deals every card' do
        # to_a should not be required here.
        # FIX: https://github.com/hamstergem/hamster/issues/182
        assert_equal 43, (
          dealt_state.hands.to_h.values.flatten +
          dealt_state.kitty
        ).to_a.uniq.size
      end

      it 'raises if deck is not large enough' do
        begin
          state(%i(a b c d))
            .deal([nil] * 42)
          fail "did not raise"
        rescue ArgumentError => e
          assert_include "fewer than 43", e.message
        end
      end
    end

    describe '#place_bid' do
      it 'replaces the current bid' do
        s = state([])
          .place_bid("first bid")
          .place_bid("newer bid")

        assert_equal "newer bid", s.bid
      end
    end

    describe '#priority_hand' do
      it 'is the hand of the player with priority' do
        s = state(%i(a b c d))
          .give_priority(:b)
          .deal(fake_deck)

        assert_equal s.hands[:b], s.priority_hand
      end
    end

    describe '#add_card_to_trick' do
      it 'moves card from priority hand to trick' do
        s = state(%i(a b c d))
          .deal(fake_deck)
          .give_priority(:c)
          .new_trick

        card = s.priority_hand[0]
        s = s.add_card_to_trick(card)

        assert_equal [card], s.trick.to_a
        assert !s.priority_hand.include?(card),
          "card was not removed from hand"
      end

      it 'raises an error if card is not in priority hand' do
        s = state(%i(a b c d))
          .deal(fake_deck)
          .give_priority(:c)
          .new_trick

        card = s.hands[:a][0]
        begin
          s.add_card_to_trick(card)
          fail "did not raise"
        rescue ArgumentError => e
          assert_include "not in hand", e.message
        end
      end
      
      # TODO: State validations on following suit etc? Or does this belong in
      # phases?
    end

    describe '#move_kitty_to_hand' do
      it 'moves cards from kitty to priority hand' do
        s = state(%i(a b c d))
          .deal(fake_deck)
          .give_priority(:c)

        kitty = s.kitty
        s = s.move_kitty_to_hand

        assert_equal [], s.kitty
        assert (s.priority_hand & kitty) == kitty
          "kitty was not added to hand"
      end
    end

    describe '#move_cards_to_kitty' do
      it 'moves cards from priority hand to kitty' do
        s = state(%i(a b c d))
          .deal(fake_deck)
          .give_priority(:c)

        cards = [s.priority_hand[0]]
        s = s.move_cards_to_kitty(cards)

        assert_include cards[0], s.kitty
        assert !s.priority_hand.include?(cards[0]),
          "card was not remvoed from hand"
      end

      it 'raises if card not in hand' do
        s = state(%i(a b c d))
          .deal(fake_deck)
          .give_priority(:c)

        cards = [s.hands[:a][0]]
        begin
          s.move_cards_to_kitty(cards)
          fail "did not raise"
        rescue ArgumentError => e
          assert_include "not in hand", e.message
        end
      end
    end
  end
end
