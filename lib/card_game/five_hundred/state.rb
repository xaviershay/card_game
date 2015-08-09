require 'hamster/hash'
require 'hamster/set'

module CardGame
  class FiveHundred
    class State
      def initialize(data = Hamster::Hash[])
        @data = data
      end

      def priority
        fetch(:priority)
      end

      def advance(attrs = {})
        merge(attrs.merge(
          priority: next_actor(priority)
        ))
      end

      def advance_dealer(attrs = {})
        merge(attrs.merge(
          dealer: next_actor(dealer)
        ))
      end

      def next_actor(actor)
        player_relative_to(actor, 1)
      end

      def player_relative_to_priority(n)
        player_relative_to(priority, n)
      end

      def player_relative_to(player, n)
        current = actors.index(player)
        actors[(current + n) % actors.size]
      end

      def won
        fetch(:won)
      end

      def actors
        fetch(:actors)
      end

      def setup_actors(actors)
        merge(
          actors: actors,
        )
      end

      def adjust_score(team, points)
        team.inject(self) do |s, player|
          s.update_in(:scores, player) {|n| n.to_i + points }
        end
      end

      def scores
        fetch(:scores)
      end

      def team_for(player)
        Hamster::Set[player, player_relative_to(player, 2)]
      end

      def won_trick(player)
        update_in(:won, player) {|n| n.to_i + 1 }
      end

      def clear_tricks
        delete(:won).delete(:trick)
      end

      def deal(hands:, kitty:)
        merge(
          hands: Hamster::Hash[hands],
          kitty: kitty
        )
      end

      def give_priority(actor)
        merge(priority: actor)
      end

      def give_deal(actor)
        merge(dealer: actor)
      end

      def dealer
        fetch(:dealer)
      end

      def reset_bid(bid)
        merge(bid: bid)
      end

      def priority_hand
        hands.fetch(priority)
      end

      def hands
        fetch(:hands)
      end

      def kitty
        fetch(:kitty)
      end

      def trick
        fetch(:trick)
      end

      def add_card_to_trick(card)
        self
          .put(:trick) {|t| t.add(card) }
          .update_in(:hands, priority) { priority_hand - [card] }
      end

      def move_cards_to_kitty(cards)
        kitty = priority_hand & cards

        self
          .update_in(:hands, priority) {|h| h - kitty }
          .put(:kitty, kitty)
      end

      def move_kitty_to_hand
        self
          .update_in(:hands, priority) {|h| h + kitty }
          .put(:kitty, [])
      end

      def new_trick
        merge(
          trick: CardGame::Trick.build([], bid.suit)
        )
      end

      def bid
        fetch(:bid)
      end

      def players
        actors.size
      end

      protected

      def merge(*args)
        self.class.new @data.merge(*args)
      end

      def update_in(*args, &block)
        self.class.new @data.update_in(*args, &block)
      end

      def fetch(*args)
        @data.fetch(*args)
      end

      def put(*args, &block)
        self.class.new @data.put(*args, &block)
      end

      def delete(*args)
        self.class.new @data.delete(*args)
      end
    end
  end
end
