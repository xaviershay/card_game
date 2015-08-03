require 'card_game/value_object'
require 'card_game/color'

module CardGame
  # Suit of a card, such as hearts or diamonds.  This is a very dumb object,
  # just providing basic equality and inspection.
  #
  # +Suit+ objects cannot be instantiated directly. Instead, use one of the
  # provided class-level builder methods.
  #
  # @attr_reader symbol [String] Pictorial representation of suit. May be
  #                              unicode.
  # @attr_reader color [Color] Color of the suit.
  class Suit
    include ValueObject

    values do
      attribute :symbol, String
      attribute :color, Color
    end

    alias_method :to_s, :symbol
    alias_method :inspect, :symbol

    # @return [Suit]
    def self.hearts;   Suit.new(symbol: "♡ ", color: Color.red) end
    # @return [Suit]
    def self.diamonds; Suit.new(symbol: "♢ ", color: Color.red) end
    # @return [Suit]
    def self.clubs;    Suit.new(symbol: "♧ ", color: Color.black) end
    # @return [Suit]
    def self.spades;   Suit.new(symbol: "♤ ", color: Color.black) end
    # @return [Suit]
    def self.none;     Suit.new(symbol: "",   color: Color.none) end

    # All suits, including +none+.
    # @return [Array<Suit>]
    def self.all
      [hearts, diamonds, clubs, spades, none]
    end

    private

    def initialize(*_)
      super
    end
  end
end
