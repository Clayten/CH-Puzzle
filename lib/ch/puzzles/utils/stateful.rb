module CH::Puzzles

  # # provides ... from has_attribute calls
  # def state #   @state_items # end
  # def self.states #   @state_templates.each { range } # must provide its own permutations # end
  # def states #   @state_items.each { range } # end
  module Stateful
    module ClassMethods
      def states
        # the combination of all possible attribute values
      end
      def attributes
        @attributes ||= Hash.new {|h,k| h[k] = {} }
      end
      def has_attribute name, possibilities = nil, args = nil
        args, possibilities = possibilities, [] if possibilities.is_a?(Hash)
        args ||= {}

        args[:possibilities] = possibilities

        # if New wraps Old, which wraps Oldest, start with new, layer it onto Old, then layer that onto Oldest.
        wraps = [args]
        p [:attributes, attributes]
        p [1, :as, args, :ws, wraps]
        loop do
          break unless args && wrap = args[:wraps] && !wrap.empty?
          require 'pry' ; binding.pry
          attrs = attributes[wrap]
          p [:attrs, attrs]
          wraps << attrs
          args = attrs[wrap]
        end
        p [2, :as, args, :ws, wraps]
        require 'pry' ; binding.pry
        args = wraps.reverse.inject({}) {|a,b| p [:a,a,:b,b] ; a.merge b }
          
        # FIXME - raise if collision?
        unless instance_methods.include? name
          # def base_value_for ...  # FIXME - fails to store
          define_method(   name   ) { instance_variables.include?(name) ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", attributes[name][:possibilities].sample) }

          define_method("#{name}=") {|x|
            raise ArgumentError, "A #{self.class.name} doesn't accept a #{name} value of #{x}" unless possibilities.include?(x)
            instance_variable_set("@#{name}", x)
          } if args[:writeable]
        end
      end
    end

    def reset_state
      attributes.each {|k,v| p [:rs, k, v] ; instance_variable_set("@#{k}", v[:possibilities].sample) }
    end

    def attributes ; @attributes ||= self.class.attributes.dup ; end
    # current state of all attributes
    def state ; @state ; end

    def initialize options = {}
      p [:init, self, options]
      options.each {|k,v|
        p [:try_set, self, k, v]
        next unless attributes.include? k
        instance_variable_set("@#{k}", v)
      }
      super()
    end
  end
end
