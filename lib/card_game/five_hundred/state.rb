require 'hamster/hash'
require 'hamster/set'
require 'hamster/deque'

require 'card_game/game'

module CardGame
  class FiveHundred
    # Immutable data object representing the state of a game of Five Hundred.
    # It does not enforce variant-specific rules. Those are left to the phases
    # and actions.
    #
    # Create a new state using the {.initial} method.
    #
    # To preseve immutability, transition methods return a new state.
    #
    # While +Player+ and +Card+ classes are used in parameter documentation for
    # clarity, they are treated as opaque objects. Any object will work. +Set+,
    # +Array+ and +Hash+ are used to express a role. The actual objects
    # returned may not be Ruby primitives, though only methods matching those
    # from primitives are considered a public API.
    class State
      # @private
      StateError = CardGame::Game::StateError

      # Construct an initial state for an array for players. The order of
      # the players should reflect their seating positions around a table:
      # element 1 is seated to the left of element 0.
      #
      # @param players [Array<Player>] all players who will be participating.
      # @return [State]
      def self.initial(players)
        new.setup_players(players)
      end

      # @!group Readers

      # @macro state_reader
      #   @!method $1
      #   @raise [CardGame::Game::StateError] when value is not present or
      #                                       available in the current state.
      # @private
      def self.state_reader(attr)
        define_method(attr) { fetch(attr) }
      end

      # All players in the game.
      # @return [Array]
      state_reader :players

      # The player whose turn it is to act.
      # @return [Player]
      state_reader :priority

      # The current dealer.
      # @return [Player]
      state_reader :dealer

      # Current scores per player. Teams are not explicitly tracked.
      # @see #adjust_score
      # @return [Hash<Player, Integer>]
      state_reader :scores

      # Number of tricks won per player. Teams are not explicitly tracked.
      # @return [Hash<Player, Integer>]
      state_reader :tricks

      # Current trick
      # @return [Array<Card>]
      state_reader :trick

      # Cards in hand for each player.
      # @return [Hash<Player, Set<Card>>]
      state_reader :hands

      # Cards in kitty.
      # @return [Set<Card>]
      state_reader :kitty

      # The current bid. Should be set to a null bid object rather than +nil+,
      # so that comparisions do not need to special case it.
      # @return [Bid]
      state_reader :bid

      # Hand of the player with priority. Short-hand for
      # +state.hands.fetch(state.priority)+ since it is needed so often.
      #
      # @return [Set<Card>]
      def priority_hand
        hands.fetch(priority)
      end

      # Return the current team for a given player. This may change each round.
      #
      # @param player [Player]
      # @return [Set<Player>]
      def team_for(player)
        if players.size != 4
          raise NotImplementedError, "Only 4-player teams are supported."
        end

        Hamster::Set[player, player_relative_to(player, 2)]
      end

      # Return a player by index from the player with priority. An index of 0
      # will return the priority player, an index of 1 the player to their
      # left, and so on.
      #
      # @param player [Player]
      # @param index [Integer]
      # @return [Player]
      def player_relative_to(player, index)
        current = players.index(player)
        players.fetch((current + index) % players.size)
      end
      
      # @!endgroup Readers
      
      # @!group Transitions

      # Pass priority to the next player. Wraps around to the start again after
      # the last one.
      #
      # @return [State]
      def advance
        put(:priority) {|x| player_relative_to(x, 1) }
      end

      # Pass dealer to the next player. Wraps around to the start again after
      # the last one.
      #
      # @return [State]
      def advance_dealer
        put(:dealer) {|x| player_relative_to(x, 1) }
      end

      # @return [State]
      # @param player [Player]
      def give_priority(player)
        put(:priority, player)
      end

      # @return [State]
      # @param player [Player]
      def give_deal(player)
        put(:dealer, player)
      end

      # Sets up initial player state. Should only be called
      # once.
      #
      # @return [State]
      # @param players [Array<Player>]
      def setup_players(players)
        merge(
          players: players,
          scores: Hamster::Hash[players.map {|p| [p, 0] }],
        ).clear_tricks
      end

      # Add or subtract points to the score of a team. A team is a set of
      # players. In some variants this set is constant over a game (such as
      # 4-handed), but in others it will change each round.  Scores are tracked
      # per-player: for constant teams, the players will always have the same
      # score.
      #
      # @return [State]
      # @param team [Set<Player>] each player will have their score adjusted
      # @param points [Integer] points to add to score. Negative points are
      #                         allowed.
      def adjust_score(team, points)
        team.inject(self) do |s, player|
          s.update_in(:scores, player) {|n| n + points }
        end
      end

      # Increments trick count for player. Should be called for the winner at
      # the conclusion of a trick.
      #
      # @param player [Player]
      # @return [State]
      def won_trick(player)
        update_in(:tricks, player) {|n| n + 1 }
      end

      # Reset trick counts to zero and delete the current trick.
      #
      # @return [State]
      def clear_tricks
        self
          .put(:tricks, Hamster::Hash[players.map {|p| [p, 0] }])
          .delete(:trick)
      end

      # Deals new hands and kitty from the provided deck.
      #
      # @return [State]
      # @param deck [Array<Card>]
      def deal(deck)
        unless players.size == 4
          raise NotImplementedError, "only 4 players are supported"
        end
        raise ArgumentError, "deck has fewer than 43 cards" if deck.size < 43

        deck = deck.shuffle

        merge(
          hands: Hamster::Hash[players.map {|p| [p, deck.shift(10)] }],
          kitty: deck.shift(3),
        )
      end

      # Set the current bid. No validation is done on whether the bid is legal.
      #
      # @param bid [Bid]
      # @return [State]
      def place_bid(bid)
        put(:bid, bid)
      end

      # Plays a card from the priority hand into the current trick. No
      # validation is done for whether the play is legal (e.g. following suit).
      #
      # @param card [Card]
      # @return [State]
      # @raise [ArgumentError] when priority hand does not include card
      def add_card_to_trick(card)
        if !priority_hand.include?(card)
          raise ArgumentError, "#{card} is not in hand of priority player"
        end

        self
          .put(:trick) {|t| t.push(card) }
          .update_in(:hands, priority) {|h| h - [card] }
      end

      # Moves cards from priority hand into the kitty. No validation is done
      # that the cards moved are legal (e.g. correct number).
      #
      # @param cards [Set<Card>]
      # @return [State]
      # @raise [ArgumentError] when priority hand does include cards
      def move_cards_to_kitty(cards)
        invalid = cards - priority_hand

        if !invalid.empty?
          raise ArgumentError, "#{cards} are not in hand of priority player"
        end

        self
          .update_in(:hands, priority) {|h| h - cards }
          .put(:kitty, cards)
      end

      # Moves all cards from kitty into priority hand.
      #
      # @return [State]
      def move_kitty_to_hand
        self
          .update_in(:hands, priority) {|h| h + kitty }
          .put(:kitty, [])
      end

      # Clear the current trick and replace it with a new empty one with the
      # current trump.
      #
      # @return [State]
      def new_trick
        put(:trick, Hamster::Deque.empty)
      end

      # @!endgroup Transitions

      protected

      def initialize(data = {})
        @data = Hamster::Hash[data]
      end

      def merge(*args)
        self.class.new @data.merge(*args)
      end

      def update_in(*args, &block)
        self.class.new @data.update_in(*args, &block)
      end

      def fetch(key, *args, &block)
        @data.fetch(key, *args, &block)
      rescue KeyError => e
        raise StateError, "State did not contain: %s. Available keys: %s." % [
          key,
          @data.keys.sort.join(", ")
        ]
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
