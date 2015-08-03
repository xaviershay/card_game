module CardGame
  # The rank of a card, either the number or face name (Jack, Queen, etc...).
  # This is a very dumb object, just providing basic equality and inspection.
  # In particular, it is not comparable for the same reason that +Card+ isn't.
  #
  # +Rank+ objects cannot be instantiated directly. Instead, use one of the
  # provided class-level builder methods.
  #
  # @attr_reader name [String] Long name.
  # @attr_reader short [String] Optional short name. Used in string
  #                             representations of cards. If no provided,
  #                             defaults to the first character of +name+.
  class Rank
    include ValueObject

    values do
      attribute :name, String
      attribute :short
    end

    # Short string representation of the rank.
    #
    # @return [String]
    def to_s
      short || name[0]
    end

    alias_method :inspect, :to_s

    # @param n [Integer]
    # @return [Rank]
    def self.numbered(n); new(name: "R#{n}", short: n.to_s) end

    # @return [Rank]
    def self.jack;  new(name: 'Jack') end
    # @return [Rank]
    def self.queen; new(name: 'Queen') end
    # @return [Rank]
    def self.king;  new(name: 'King') end
    # @return [Rank]
    def self.ace;   new(name: 'Ace') end
    # @return [Rank]
    def self.joker; new(name: 'Joker', short: 'Jk') end

    # All known ranks.
    #
    # @return [Array<Rank>]
    def self.all
      numbers + faces + [ace, joker]
    end

    # The numbers 2 to 10. Decks with higher numbers are not yet supported.
    #
    # @return [Array<Rank>]
    def self.numbers
      (2..10).map {|n| numbered(n) }
    end

    # The three face ranks: Jack, Queen, and King.
    # @return [Array<Rank>]
    def self.faces
      [jack, queen, king]
    end

    private

    def initialize(*args)
      super
    end
  end
end
