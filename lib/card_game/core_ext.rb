require 'card_game/card'

module CardGame
  # These are silly monkeypatches that you probably don't want to use in real life
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

class String
  include CardGame::CoreExt
end

class Integer
  include CardGame::CoreExt
end
