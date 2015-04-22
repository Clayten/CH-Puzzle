module CH
  module Puzzles
    def self.dirname ; self.name.gsub(/::/,'/').gsub(/([a-z])([A-Z])/,'\1_\2').downcase ; end
    def self.libdir ; File.join(File.dirname(File.realdirpath(__FILE__)),'..') ; end
    def self.reload ; load __FILE__ ; Dir.glob("#{libdir}/#{dirname}/**/*.rb").each {|f| load f } ; end
  end
end
