CardGame
========

Ruby utility library for various card games.

Really just me playing around with design ideas.

Synopsis
--------

You can compare poker hands.

    require 'card_game/poker'

    include CardGame

    Poker.classify(Hand.build("10H JH QH KH AH")) >
    Poker.classify(Hand.build("AH AD AS AC KH"))
    # => true

You can calculate winning cards in Five hundred tricks.

    require 'card_game/five_hundred'

    FiveHundred.winning_card(Trick.new(
      cards: Hand.build("10S JD AH 10D"),
      trump: Suit.hearts,
    ))
    # => Card.from_string("JD")

    FiveHundred.winning_card(Trick.new(
      cards: Card.array_from_string("10S JD AH 10D"),
      trump: Suit.clubs,
    ))
    # => Card.from_string("10S")
