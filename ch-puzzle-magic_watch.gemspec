# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ch/puzzle/magic_watch/version'

Gem::Specification.new do |spec|
  spec.name          = "ch-puzzle-magic_watch"
  spec.version       = CH::Puzzle::MagicWatch::VERSION
  spec.authors       = ["Clayten Hamacher"]
  spec.email         = ["clayten.hamacher@gmail.com"]
  spec.summary       = %q{An interactive toolkit for the MagicWatch puzzle described at http://wiki.xkcd.com/irc/Puzzles#Magic_Watch}
  spec.homepage      = ""
  spec.license       = "AGPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pry",     "~> 0.10"
  spec.add_runtime_dependency "pry-doc", "~> 0.6"
  spec.add_runtime_dependency "pry-nav", "~> 0.2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "shoulda-context"

  spec.description   = <<DOC
A game where you use a limited number of queries of a perfect oracle to figure out a secret and win a prize!

Running the binary will drop you in pry in the MagicWatch simulator.

You can create a watch, a cabinet, and a game simulator (which will provides you with a watch and cabinet). You then interact with the Ruby object in a way that enforces the rules of the game (you can't accidentally cheat) and lets you test both your code and your solution.

To build your solver you simply take the simply interactive commands you've been running to query the watch and guess a door and bundle them into a method, which automates the process.
DOC
end
