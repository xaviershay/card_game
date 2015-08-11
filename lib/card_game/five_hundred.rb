require 'card_game/card'
require 'card_game/ordering'
require 'card_game/trick'
require 'card_game/game'

require 'card_game/five_hundred/state'

module CardGame
  # Utility methods for modeling five hundred.
  class FiveHundred
    # @private
    OPPOSITES = {
      Suit.hearts   => Suit.diamonds,
      Suit.diamonds => Suit.hearts,
      Suit.clubs    => Suit.spades,
      Suit.spades   => Suit.clubs,
    }

    # Returns the winning card of a given trick, accounting for trumps, bowers,
    # and the Joker.
    #
    # @param trick [Trick]
    # @return [Card]
    def self.winning_card(trick)
      led = trick.cards.first

      raise(ArgumentError, "Trick must contain at least one card") unless led

      opposite = OPPOSITES.fetch(trick.trump) { Suit.none }
      left_bower  = Card.new(rank: Rank.jack, suit: opposite)
      right_bower = Card.new(rank: Rank.jack, suit: trick.trump)
      joker       = Card.new(rank: Rank.joker, suit: Suit.none)

      trick.cards.sort_by(&Ordering.composite(
        Ordering.match(joker),
        Ordering.match(right_bower),
        Ordering.match(left_bower),
        Ordering.suit(trick.trump),
        Ordering.suit(led.suit),
        Ordering.by_rank(ALL_RANKS),
      )).last
    end

    # Creates a deck suitable for Five Hundred.
    #
    # @param players [Integer] The number of players. Must be between 3 and 6.
    # @return [Array<Card>]
    def self.deck(players: 4)
      joker = [Card.unsuited(Rank.joker)]

      ranks_for_colors = DECK_SPECIFICATION.fetch(players) {
        raise ArgumentError,
          "Only 3 to 6 players are supported, not #{players}"
      }

      joker + ALL_RANKS.product(Suit.all)
        .map {|rank, suit| Card.build(rank, suit) }
        .select {|card|
          ranks_for_colors.fetch(card.suit.color).include?(card.rank)
        }
    end

    make_ranks = -> r {
      r.map(&Rank.method(:numbered)) + Rank.faces + [Rank.ace]
    }

    # Deck specifications for different numbers of players.
    #
    # @private
    DECK_SPECIFICATION = {
      3 => {
        Color.red   => make_ranks.(7..10),
        Color.black => make_ranks.(7..10),
      },
      4 => {
        Color.red   => make_ranks.(4..10),
        Color.black => make_ranks.(5..10),
      },
      5 => {
        Color.red   => make_ranks.(2..10),
        Color.black => make_ranks.(2..10),
      },
      6 => {
        Color.red   => make_ranks.(2..13),
        Color.black => make_ranks.(2..12),
      }
    }

    # All known ranks.
    #
    # @private
    ALL_RANKS = DECK_SPECIFICATION.fetch(6)[Color.red]

    def self.play(players: 4)
      Game.new(Phase::Setup, players)
    end

    module Action
      # TODO: This is actual CoreBid
      class Core < Game::Action
        include Comparable

        def <=>(other)
          key <=> other.key
        end
      end

      class Bid < Core
        values do
          attribute :number, Integer
          attribute :suit, Suit
        end

        def self.build(actor, number, suit)
          new(actor: actor, number: number, suit: suit)
        end

        def key
          [number]
        end

        def score
          suit_score = [
            Suit.spades,
            Suit.clubs,
            Suit.diamonds,
            Suit.hearts,
            Suit.none
          ].index(suit) * 20 + 40

          (number - 6) * 100 + suit_score
        end

        def to_s
          "<Bid %s %i%s>" % [actor, number, suit]
        end
        alias_method :inspect, :to_s

        def pretty_print(pp)
          pp.text(to_s)
        end
      end

      class Pass < Core
        def self.build(actor)
          new(actor: actor)
        end

        def key
          [0]
        end
      end

      class Play
        include ValueObject

        values do
          attribute :actor
          attribute :card, Card
        end
      end

      class Kitty
        include ValueObject

        values do
          attribute :actor
          attribute :cards, [Card]
        end
      end
    end

    class Player < Game::Player
      def bid(n, suit)
        Action::Bid.build(self, n, suit)
      end

      def pass
        Action::Pass.build(self)
      end

      def play(card)
        Action::Play.new(actor: self, card: card)
      end

      def kitty(cards)
        Action::Kitty.new(actor: self, cards: cards)
      end
    end

    module Phase
      Abstract = CardGame::Game::Phase

      class Setup < Abstract
        def enter
          players = (1..state).map {|x| Player.new(position: x) }
          
          State.initial(players)
            .give_deal(players.first) # TODO: sample, store seed in state
        end

        def transition
          NewRound
        end
      end

      class NewRound < Abstract
        def enter
          deck = FiveHundred.deck(players: state.players.size)

          state
            .deal(deck)
            .advance_dealer
            .give_priority(state.dealer)
            .place_bid(Action::Pass.new({}))
        end

        def transition
          Bidding
        end
      end

      module RequirePriority
        def apply(action)
          super

          if action.actor != state.priority
            raise "#{action.actor} may not act, #{state.priority} has priority"
          end
        end
      end

      class Bidding < Abstract
        include RequirePriority

        def apply(action)
          super

          if action > state.bid
            state.advance.place_bid(action)
          else
            state.advance
          end
        end

        def transition
          Kitty if state.bid.actor == state.priority
        end
      end

      class Kitty < Abstract
        include RequirePriority

        def enter
          state.move_kitty_to_hand
        end

        def apply(action)
          super

          state.move_cards_to_kitty(action.cards)
        end

        def transition
          Phase::Trick if state.kitty.size == 3
        end
      end

      class Trick < Abstract
        include RequirePriority

        def enter
          state.new_trick
        end

        def exit
          # TODO: Figure out a way to clean this up
          card = FiveHundred.winning_card(
            CardGame::Trick.build(state.trick.to_a, state.bid.suit)
          )
          i = state.trick.to_a.index(card)

          winner = state.player_relative_to(state.priority, i)

          state
            .won_trick(winner)
            .give_priority(winner)
        end

        def apply(action)
          super

          case action
          when Action::Play
            state

            if !state.priority_hand.include?(action.card)
              raise "#{action.card} is not in hand of #{action.actor}"
            end

            state
              .add_card_to_trick(action.card)
              .advance
          end
        end

        def transition
          return Scoring if state.hands.values.all?(&:empty?)
          return Trick if state.trick.size == state.players
        end
      end

      class Scoring < Abstract
        def enter
          bidding_team = state.team_for(state.bid.actor)
          tricks_won = bidding_team.map do |actor|
            state.tricks.fetch(actor)
          end.reduce(:+)

          new_state = if tricks_won > state.bid.number
            state
              .adjust_score(bidding_team, state.bid.score)
          else
            state
              .adjust_score(bidding_team, -state.bid.score)
          end

          opposing_team = state.players - bidding_team

          tricks_won = opposing_team.map do |actor|
            new_state.tricks.fetch(actor)
          end.reduce(:+)

          new_state
            .adjust_score(opposing_team, tricks_won * 10)
        end

        def exit
          state.clear_tricks
        end

        def transition
          if state.scores.values.any? {|x| !(-500..500).cover?(x) }
            Completed
          else
            NewRound
          end
        end
      end

      class Completed < Abstract
      end
    end
  end
end
