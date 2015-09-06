require 'hamster/hash'
require 'hamster/vector'
require 'hamster/deque'

module CardGame
  class Poker
    class State
      def initialize(initial = {})
        @data = Hamster::Hash[initial]
      end

      def self.default(players:, buy_in:)
        players = Hamster::Vector[*players.times.map {|i| Player.new(position: i+1) }]

        new(
          players: players,
          chips: Hamster::Hash[ players.map {|player| [player, buy_in] } ]
        )
      end

      def clear_table
        self
          .empty_pot
          .merge(table: Hamster::Vector[])
      end

      def dealer
        fetch(:dealer)
      end

      def empty_pot
        merge(
          pot: Hamster::Hash[players.map {|p| [p, 0] }],
          active: players.dup
        )
      end

      def give_deal(actor)
        merge(dealer: actor)
      end

      def give_pot_to_player(player)
        merge(
          chips: chips.put(player) {|chips| chips + pot.values.reduce(:+) }
        ).empty_pot
      end

      def players
        fetch(:players)
      end

      def chips
        fetch(:chips)
      end

      def pot
        fetch(:pot)
      end

      def active
        fetch(:active)
      end

      def advance
        merge(
          priority: next_active(priority)
        )
      end

      def left_of_dealer
        i = actors.index(dealer)
        actors[(i+1) % actors.size]
      end

      def give_priority(actor)
        merge(priority: actor)
      end

      def next_active(actor)
        i = active.index(actor)
        active[(i+1) % active.size]
      end

      def fold(actor)
        advance.merge(
          active: fetch(:active).delete(actor)
        )
      end

      def raise_bet(actor, amount)
        call = pot.values.max - pot.fetch(actor)

        amount += call
        advance.merge(
          chips: chips.put(actor) {|current| current - amount },
          pot:   pot.put(actor) {|current| current + amount },
          last_raiser: actor,
        )
      end

      def call_bet(actor)
        call = pot.values.max - pot.fetch(actor)

        advance.merge(
          chips: chips.put(actor) {|current| current - call },
          pot:   pot.put(actor) {|current| current + call },
          last_raiser: last_raiser || actor,
        )
      end

      def deck
        fetch(:deck)
      end
      
      def reset_deck(deck)
        merge(deck: Hamster::Deque[*deck])
      end

      def deal_community_cards(n)
        d = deck
        single = -> _ { d.first.tap { d = d.shift } }

        deal = n.times.map(&single)

        merge(
          deck: d,
          table: table + deal
        )
      end

      def deal_hand_cards(n)
        d = deck
        single = -> _ { d.first.tap { d = d.shift } }
        hs = actors.map {|actor| [actor, n.times.map(&single)] }.to_h

        merge(
          hands: hs,
          deck: d
        )
      end

      def hand(actor)
        fetch(:hands).fetch(actor)
      end

      def clear_last_raiser
        merge(last_raiser: nil)
      end

      def setup(*args)
        merge(*args)
      end

      def table
        fetch(:table)
      end

      def actors
        fetch(:players)
      end

      def deal(hands)
        merge(hands: hands)
      end

      def priority
        fetch(:priority)
      end

      def last_raiser
        fetch(:last_raiser)
      end

      protected

      def merge(*args)
        self.class.new @data.merge(*args)
      end

      def fetch(*args)
        @data.fetch(*args)
      end

      def delete(*args)
        self.class.new @data.delete(*args)
      end
    end
  end
end
