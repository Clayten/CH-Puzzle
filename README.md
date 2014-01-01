# CH::Puzzle::MagicWatch

This gem implements the Magic Watch puzzle describe at http://wiki.xkcd.com/irc/Puzzles#Magic_Watch

You have a magic watch with flawlessly and omnisciently answers two true-or-false questions per day (game). The trick is that the watch answers with  :yellow/:blue  instead of true/false, and which color means which switches randomly and unfathomably (can't be queried in advance) at the beginning of each day (game).

You have been chosen to participate in a game-show where you will have one guess to pick the correct door of three (randomly chosen each game), winning a car instead of a goat.

Use your magic watch to increase your odds of winning - how good can you make your odds?

The DoorGuesser.play method creates a new prize-cabinet and magic watch, if a block is passed it is called with these arguments and its final value (0..2) is used as a guess

DoorGuesser.play {|game, watch|
  ... # queries
  ... # guess - (0..2)
}

or, the direct method

game, watch = DoorGuesser.play
game
 => <DoorGuesser:43879520 [----] [----] [----]>

No idea what's where...

watch
=> <Watch:44599200 @questions=2, @free_recursion=false>

Looks like any ordinary magic watch. It's got two questions remaining today.

watch.ask { game.first == :car }
 => :yellow
watch.ask { game.middle == :car }
 => :yellow

Aha! By deduction you've found the car! You know there can't be two cars so :yellow must currently mean false and so the car must really be the one you haven't looked at. It's lucky this configuration came up.

game.guess 2
 => true

Let's have a look

game.peek
 => [:goat, :goat, :car]
game
 => <DoorGuesser:43879520 [goat] [goat] [car ]>

Neat, let's try again!

game, watch = DoorGuesser.play
game.peek
 => RuleViolation: "You can't peek until after you've guessed."

Grumble...

watch.truth_color
 => EncapsulationViolation: "You can't look directly"

Hmf... Can't know without asking.

watch.ask { true }
 => :yellow
watch.questions
 => 1

Okay, at the cost of a question we can figure out the current truthiness

watch.ask { game.first }
 => ImproperQuestion: "Only true/false questions"
watch.questions
 => 1

At least it didn't cost a question to get that...

## Installation

Add this line to your application's Gemfile:

    gem 'ch-puzzle-magic_watch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ch-puzzle-magic_watch

## Usage

TODO: Write usage instructions here

## Contributing

Doc writers, coders, reviewers, and those with clever solutions or handy libraries of propositions! This is a project for a broad audience, in ages and interests, and should be as accessible and clear as possible while understaning that some measure of terseness is clarity.

Initial usability is paramount, meaning this README, the rdoc (generated from comments), and the examples, and then the code itself. Continue to push any implementation ugliness (instance_eval? singleton_method??) under the rug to make this more of a newbie-friendly logic puzzle instead of an intro to the crufty corners of the language, and make it outwardly more consistent between languages if ported.

Consider writing other puzzles. Different restrictions on the watch, different numbers of guesses, more doors, etc.

When creating other games, add them alongside MagicWatchGame, and use MagicWatch and PrizeCabinet as appropriate. Try to be unique with names. One file per game (unless that's silly - as where two games are only a slight variation apart), even if that's a bunch by one author.

Propositions, such as   door1_or_door2   if these are commom and everyone would reinvent them. Note that reading some of these propositions may involve spoilers. Where it isn't obvious, include a truth table in comments.

Guessers, a chooser that, with supplied propositions, attempts to select a car. These don't have to be great, and in fact should include pathological examples such as BlindGuesser as well. Where it's not obvious, explain the choices made in comments. These are a block that can be provided to ...Game.play

Not least, though last, cheats. Ways to be rewarded for victory without going through the hoops the game designers had in mind. The real fun.

1. Fork it (via github or `git clone https://...`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Spoilers

You can get 100% with no guessing or cheating.

### Advanced querying

So what was that free recursion thing?

watch = Watch.new
watch.ask { game.first == :car }
 => :yellow
watch.ask { game.middle == :car }
 => :blue
watch.questions
 => 0

Okay, simple enough.

watch = Watch.new
watch.ask { watch.ask { w.truth_color == :yellow } == :blue }
watch.questions
=> 0

Wait... Was that one or two?

watch = Watch.new :free_recursion => true
watch.ask { watch.ask { w.truth_color == :yellow } == :blue }
watch.questions
=> 1
 
Aha.... Questions inside questions. It's all a true/false anyways, so why should they cost more, right...?

There're simpler solutions possible if you play with free recursive questions. It's probably fun to find both types.

### Cheating?

Looking inside the prize cabinet before it's been opened, influencing the contents of the cabinet, finding a way to make your guess count more than once, finding a way to get more questions from the watch per game, finding out the truthiness of the watch without asking questions, and a ton of other methods.

I've gone far enough to prevent accidental mistakes by defining inspect methods so as to not dump the internal state in your face while you're playing, but it'd be impossible to stop cheating even if there was a reason to try.

For instance, watch.instance_variable_get(:@t) => :yellow
or            watch.instance_variable_set(:@questions, 9**9) => 387420489
or            game.dup.guess(0) ; game.dup.guess(1) ; ...
or            game.instance_eval do @rooms = @rooms.collect { :car } ; end

If you come up with any particularly clever ones, see the contributions section above. Note, as a hacker and presumed advanced user it's your job to cleanup after your cheat, if it involved overriding something in Kernel for instance, so that it can be loaded from irb/pry and safely played with by a novice. Cheats also need tests and good documention.
