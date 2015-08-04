require 'card_game/card'

module CardGame
  # These are silly monkey-patches for constructing cards that you probably
  # don't want to use in real life.
  #
  # @example
  #     require 'card_game/core_ext'
  #
  #     4.hearts
  #     4.♥️︎
  #     "A".♣️
  module CoreExt
    # @return [Card]
    def hearts
      CardGame::Card.from_string("#{self}H")
    end

    alias_method :♡, :hearts
    alias_method :♥︎, :hearts
    alias_method :♥️︎, :hearts

    # @return [Card]
    def diamonds
      CardGame::Card.from_string("#{self}D")
    end

    alias_method :♢, :diamonds
    alias_method :♦︎, :diamonds
    alias_method :♦️, :diamonds

    # @return [Card]
    def clubs
      CardGame::Card.from_string("#{self}C")
    end

    alias_method :♧, :clubs
    alias_method :♣︎, :clubs
    alias_method :♣️, :clubs

    # @return [Card]
    def spades
      CardGame::Card.from_string("#{self}S")
    end

    alias_method :♤, :spades
    alias_method :♠︎, :spades
    alias_method :♠️︎, :spades
  end
end

# Monkey-patches only applied if +card_game/core_ext+ is explicitly required.
#
# @see CardGame::CoreExt
class String
  include CardGame::CoreExt
end

# Monkey-patches only applied if +card_game/core_ext+ is explicitly required.
#
# @see CardGame::CoreExt
class Integer
  include CardGame::CoreExt
end
