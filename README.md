CardGame
========

Ruby utility library for various card games.

Really just me playing around with design ideas.

Synopsis
--------

You can compare poker hands.

``` ruby
require 'card_game/poker'

include CardGame

Poker.classify(Hand.build("10H JH QH KH AH")) >
Poker.classify(Hand.build("AH AD AS AC KH"))
# => true
```

You can calculate winning cards in Five Hundred tricks.

``` ruby
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
```

You can play a simple game of Five Hundred. (This is experimental and
incomplete.)

``` ruby
require 'card_game/five_hundred'

game = CardGame::FiveHundred.play(players: 4)

players = game.state.players
hand = -> player { game.state.hands.fetch(player) }

game.apply players[0].bid(6, CardGame::Suit.hearts)
game.apply players[1].pass
game.apply players[2].bid(7, CardGame::Suit.hearts)
game.apply players[3].pass
game.apply players[0].pass
game.apply players[1].pass

game.apply players[2].kitty(hand.(players[2]).take(3))

(0..9).each do
  i = players.index(game.state.priority)
  game.apply players[(i+0) % 4].play(hand.(players[(i+0) % 4])[0])
  game.apply players[(i+1) % 4].play(hand.(players[(i+1) % 4])[0])
  game.apply players[(i+2) % 4].play(hand.(players[(i+2) % 4])[0])
  game.apply players[(i+3) % 4].play(hand.(players[(i+3) % 4])[0])
end

require 'pp'
pp game.state
```

There are also silly monkeypatches you probably don't want to use in real life,
but make for fun READMEs.

``` ruby
require 'card_game/core_ext'

FiveHundred.winning_card(Trick.new(
  cards: [ "A".♡, 5.♢, 10.♧, "A".♢ ],
  trump: Suit.♢,
))
# => Card.from_string("AD")
```

Developing
----------

    bundle install
    bin/test
