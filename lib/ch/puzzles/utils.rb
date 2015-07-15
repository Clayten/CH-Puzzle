module CH
  module Puzzles
    require 'ch/puzzles/utils/encapsulation'
    require 'ch/puzzles/utils/resettable'
    require 'ch/puzzles/utils/stateful'

    def utilize *args
      args.each {|arg|
        include arg
        next unless arg.const_defined? :ClassMethods
        extend eval "#{arg.name}::ClassMethods"
      }
    end
  end
end
