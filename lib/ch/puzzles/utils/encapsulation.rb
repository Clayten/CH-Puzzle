require 'ch/puzzles/utils'
module CH::Puzzles
  class EncapsulationViolation < RuntimeError ; end

  module Encapsulator
    module ClassMethods
      private
      def encapsulation_signature ; /\`ask'/ ; end
      def encapsulation_level   ; caller.select {|c| c =~ encapsulation_signature }.length ; end
      def encapsulation_check   ; !encapsulation_level.zero? ; end
      def enforce_encapsulation ; raise EncapsulationViolation, "You can't look directly"                  unless encapsulation_check ; end
      def refute_encapsulation  ; raise EncapsulationViolation, "You cannot modify anything while asking"  if     encapsulation_check ; end
    end
    private
    def      encapsulation_level   ; self.class.send :encapsulation_level   ; end
    def      enforce_encapsulation ; self.class.send :enforce_encapsulation ; end
    def       refute_encapsulation ; self.class.send :refute_encapsulation  ; end
  end

  module Encapsulated
    module ClassMethods
      private
      def default_encapsulator ; Oracles ; end
    end
    private
    attr_reader :encapsulator

    def      default_encapsulator ; self.class.default_encapsulator ; end
    def    enforce_encapsulation  ; encapsulator.send :enforce_encapsulation ; end
    def     refute_encapsulation  ; encapsulator.send :refute_encapsulation  ; end
  end
end
