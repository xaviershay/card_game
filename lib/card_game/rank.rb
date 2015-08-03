module CardGame
  # The rank of a card, either the number or face name (Jack, Queen, etc...).
  # This is a very dumb object, just providing basic equality and inspection.
  class Rank
    include ValueObject

    values do
      attribute :name, String
      attribute :short
    end

    # Short string representation of the rank.
    def to_s
      short || name[0]
    end

    alias_method :inspect, :to_s

    def self.numbered(n); new(name: "R#{n}", short: n.to_s) end

    def self.jack;  new(name: 'Jack') end
    def self.queen; new(name: 'Queen') end
    def self.king;  new(name: 'King') end
    def self.ace;   new(name: 'Ace') end
    def self.joker; new(name: 'Joker', short: 'Jk') end

    def self.all
      numbers + faces + [ace, joker]
    end

    def self.numbers
      (2..10).map {|n| numbered(n) }
    end

    def self.faces
      [jack, queen, king]
    end

    private

    def initialize(*args)
      super
    end
  end
end
