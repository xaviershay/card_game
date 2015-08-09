require 'card_game/game'

require 'card_game/poker/patterns'
require 'card_game/poker/deck'
require 'card_game/poker/state'

module CardGame
  # Utility methods for modeling poker.
  class Poker
    # Returns a comparable pattern object describing the hand. Higher hands
    # will sort above lower hands. Never returns +nil+: Hands with nothing
    # interesting return a high card pattern.
    #
    # Standard poker rules are used. Suits are ignored.
    #
    # @return [Comparable]
    # @param hand [Card] hand to classify. Usual length is five,
    #                    though not required.
    def self.classify(hand)
      Patterns::ALL
        .lazy
        .map {|matcher| matcher.apply(hand) }
        .detect(
          ->{ raise "Assertion failed: no matching pattern for #{hand}" }
        ) {|x| x }
    end

    # Creates a deck suitable for poker.
    #
    # @return [Array<Card>]
    def self.deck
      Deck.deck
    end

    def self.texas_holdem(players:, buy_in: 100)
      Game.new(Phase::Setup, State.default(players: players, buy_in: buy_in))
    end

    module Phase
      class Setup < Game::Phase
        def enter
          state
            .give_deal(state.players.first) # TODO: Shuffle
        end

        def transition
          NewRound
        end
      end

      class NewRound < Game::Phase
        def enter
          deck = Poker.deck.shuffle

          state
            .clear_table
            .reset_deck(deck)
            .deal_hand_cards(2)
            .give_priority(state.left_of_dealer)
        end

        def transition
          Betting
        end
      end

      class Betting < Game::Phase
        def enter
          state
            .clear_last_raiser
        end

        def apply(action)
          if action.actor != state.priority
            raise "#{action.actor} cannot go, waiting for #{state.priority}"
          end

          case action
          when Action::Fold
            state.fold(action.actor)
          when Action::Raise
            state.raise_bet(action.actor, action.chips)
          when Action::Call
            state.call_bet(action.actor)
          end
          # TODO: Call sets last_raiser if none already
        end

        def transition
          return EndRound if state.active.size == 1
          if state.last_raiser == state.priority
            if state.table.size < 5
              return CommunityCard 
            else
              return DecideRound
            end
          end
        end
      end

      class CommunityCard < Game::Phase
        def enter
          n = if state.table.size == 0
            3
          else
            1
          end

          state.deal_community_cards(n)
        end

        def transition
          Betting
        end
      end

      class EndRound < Game::Phase
        def enter
          state
            .give_pot_to_player(state.active[0])
        end

        def transition
          if state.chips.count {|_, chips| chips > 0 } > 1
            NewRound
          else
            Completed
          end
        end
      end

      class DecideRound < EndRound
        def enter
          # TODO: Use best 5, not all 7
          winner = state.active.sort_by do |actor|
            Poker.classify(state.hand(actor) + state.table)
          end.last

          state
            .give_pot_to_player(winner)
        end
      end


      class Completed < Game::Phase
      end
    end

    class Player < Game::Player
      def fold
        Action::Fold.build(self)
      end

      def call_bet
        Action::Call.build(self)
      end

      def raise_bet(chips)
        Action::Raise.build(self, chips)
      end
    end

    module Action
      class Fold < Game::Action
      end

      class Call < Game::Action
      end

      class Raise < Game::Action
        values do
          attribute :chips, Integer
        end

        def self.build(actor, chips)
          new(actor: actor, chips: chips)
        end
      end
    end
  end
end
