require 'card_game/value_object'

module CardGame
  # Color of a suit, such as red or black. This is a very dumb object, just
  # providing basic equality and inspection.
  #
  # +Color+ objects cannot be instantiated directly. Instead, use one of the
  # provided class-level builder methods.
  #
  # @attr_reader name [String] Name of the color.
  class Color
    include ValueObject

    values do
      attribute :name, String
    end

    # @private
    Red   = new(name: "red")
    # @private
    Black = new(name: "black")
    # @private
    None  = new(name: "none")

    # @return [Color]
    def self.red; Red end
    # @return [Color]
    def self.black; Black end
    # @return [Color]
    def self.none; None end

    private

    def initialize(*_)
      super
    end
  end
end
