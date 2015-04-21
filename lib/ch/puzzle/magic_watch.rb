module CH
  module Puzzle
    module MagicWatch
      LIBS rescue LIBS = %w(version magic_watch prize_cabinet guessing_game guessers/non-recursive)

      def self.dirname ; self.name.gsub(/::/,'/').gsub(/([a-z])([A-Z])/,'\1_\2').downcase ; end
      def self.libdir ; File.join(File.dirname(File.realdirpath(__FILE__)),'..','..') ; end
      def self.reload ; load __FILE__ ; Dir.glob("#{libdir}/#{dirname}/**/*.rb").each {|f| load f } ; end

      $LOAD_PATH << libdir unless $LOAD_PATH.include? libdir
      LIBS.each {|l| require "#{dirname}/#{l}" }
    end
  end
end
