#!/usr/bin/env ruby

# Just a description so far...
#
# A twelve-sided die, but round. Each "face" has a hole. There are eleven balls and one empty hole.
#
# By pressing a ball adjacent to the space down and towards the space, you can shift them one-by-one in a manner
# similar to the 4x4 form of this puzzle, where one of the sixteen tiles is missing.
#
# The faces are colored, as are the balls. The goal is to match all colors.
#
# Current layout
#
# Faces:
# Bottom: White
# Lower row - starting to the right of the label: Blue, Purple, L Green, L Blue, Red
# Upper row - starting "between" B and P below:   Orange, L Purple, Pink, Yellow, Green
# Top: Black
#
# Balls: (In the same order) - There is no white ball
# Bottom: Empty
# LR: Blue, Purple, LGreen, Green, Red
# UR: Orange, LBlue, Pink, Yellow, Purple
# Top: Black
#
# Connections:
# Each piece is connected to the five nearest. The top and bottom are, respectively, each connected to their entire neighboring row.
# Orange, for example, is connected to Blue, Purle, Green, LPurple, and Black.
#
#
