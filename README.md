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
