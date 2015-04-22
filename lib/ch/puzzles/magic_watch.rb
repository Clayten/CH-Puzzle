require 'ch/puzzles'
module CH
  module Puzzles
    module MagicWatch
      LIBS rescue LIBS = %w(watch cabinet game guessers/non-recursive)

      def self.dirname ; self.name.gsub(/::/,'/').gsub(/([a-z])([A-Z])/,'\1_\2').downcase ; end
      def self.libdir ; File.join(File.dirname(File.realdirpath(__FILE__)),'..','..') ; end
      def self.reload ; CH::Puzzles.reload ; end

      LIBS.each {|l| require "#{dirname}/#{l}" }
    end
  end
end
