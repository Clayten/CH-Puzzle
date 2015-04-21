$guesser = lambda {|game, watch|

  prop :door1 do game.first  == :car end
  prop :door2 do game.middle == :car end
  prop :door3 do game.last   == :car end

  prop :truth_is_yellow do watch.truth_color == :yellow end
  prop :truth_is_blue   do watch.truth_color == :blue   end

   first_color = watch.ask { ( door1           && truth_is_yellow) || (          door3  && truth_is_blue) }
  second_color = watch.ask { ((door1 || door2) && truth_is_yellow) || ((door2 || door3) && truth_is_blue) }

  if first_color != second_color
    1
  elsif first_color == :yellow
    0
  else
    2
  end
}

# obsolete form using lambdas as an example
# $dgl = lambda {|game, watch|
# 
#   door1 = lambda { game.first  == :car }
#   door2 = lambda { game.middle == :car }
#   door3 = lambda { game.last   == :car }
# 
#   truth_is_yellow = lambda { watch.truth_color == :yellow }
#   truth_is_blue   = lambda { watch.truth_color == :blue   }
# 
#    first_color = watch.ask { ( door1.call                && truth_is_yellow.call) || (               door3.call  && truth_is_blue.call) }
#   second_color = watch.ask { ((door1.call || door2.call) && truth_is_yellow.call) || ((door2.call || door3.call) && truth_is_blue.call) }
# 
#   if first_color != second_color
#     1
#   elsif first_color == :yellow
#     0
#   else
#     2
#   end
# }

# truth table
#      -- inputs --
# watch         guessing game     propositions                                             color_one                                       color_two    - final combo
# truth-color door1 door2 door3 - truth_is_yellow truth_is_blue first_and_tiy last_and_tib fiy_or_lab   not_last_and_tiy not_first_and_tib nlay_or_nfab - color1 & color2/door
# yellow      car   goat  goat    true /yellow    false/blue    true /yellow  false/blue   true /yellow true /yellow     false/blue        true /yellow - yellow & yellow/first
# yellow      goat  car   goat    true /yellow    false/blue    false/blue    false/blue   false/blue   true /yellow     false/blue        true /yellow - blue   & yellow/middle
# yellow      goat  goat  car     true /yellow    false/blue    false/blue    false/blue   false/blue   false/blue       false/blue        false/blue   - blue   & blue  /last
# blue        car   goat  goat    false/yellow    true /blue    false/yellow  false/yellow false/yellow false/yellow     false/yellow      false/yellow - yellow & yellow/first
# blue        goat  car   goat    false/yellow    true /blue    false/yellow  false/yellow false/yellow false/yellow     true /blue        true /blue   - yellow & blue  /middle
# blue        goat  goat  car     false/yellow    true /blue    false/yellow  true /blue   true /blue   false/yellow     true /blue        true /blue   - blue   & blue  /last
#
# c1 == c2 == :yellow   c1 != c2            c1 == c2 == :blue
# first-door            middle-door         last-door
