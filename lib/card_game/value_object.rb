module CardGame
  # Provides typed attributes, nice inspect output, and value equality. Last
  # measured it was about an order of magnitude faster than Virtus. +values+
  # block is optional, but provided for API compatibility with Virtus.
  #
  # @example
  #     class Person
  #       values do
  #         attribute :name, String
  #         attribute :age, Integer
  #         attribute :nick_names, [String]
  #       end
  #     end
  #
  #     Person.new(name: "Don", age: 42, nick_names: %w(Donny))
  module ValueObject
    # @private
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.attributes # Force instantiation
    end

    # @param data Hash hash of attribute to value mappings.
    # @raise ArgumentError if any provided attributes were not defined by
    #                      +.attribute+ on the class.
    # @raise ArgumentError if any values do not match defined types.
    def initialize(data)
      data.each do |key, value|
        type = self.class.attributes[key]
        if type
          if self.class.of_type?(type, value)
            instance_variable_set("@#{key}", value)
          else
            raise ArgumentError, "#{type} !== #{value} for #{key}"
          end
        else
          raise ArgumentError, "Unknown attribute #{self.class.name}##{key}"
        end
      end
    end

    # Delegates to an array composed of all attribute values.
    def ==(other)
      equality_key == other.equality_key
    end

    # Delegates to an array composed of all attribute values.
    def eql?(other)
      equality_key.eql?(other.equality_key)
    end

    # Delegates to an array composed of all attribute values.
    def hash
      equality_key.hash
    end

    # Compact string representation of the object, showing all attribute
    # values.
    def to_s
      keyvalues = self.class.attributes.map {|key, _|
        "#{key}=#{send(key).inspect}"
      }.join(" ")

      "<#{self.class.name} #{keyvalues}>"
    end

    alias_method :to_s, :inspect

    # @private
    def equality_key
      self.class.attributes.map {|key, _|
        send(key)
      }
    end

    # Class methods that will be added when +ValueObject+ is included. Do not
    # use directly.
    module ClassMethods
      # Evaluates the given block. Effectively a no-op passthrough. Provided
      # for API compatibilty with Virtus.
      def values(&block)
        instance_eval(&block)
      end

      # @private
      def attributes
        @attributes ||= {}
      end

      # Defines an attribute on the value object. Creates an reader method for
      # the attribute and allows it to be set in the constructor.
      #
      # @param name [String/Symbol] name of the attribute
      # @param type [Class] required type of attribute values. Passing an
      #                     +Array+ with a single value specifies an array of
      #                     that class. Note that by specifying a non-+Object+
      #                     class, +nil+ values will not be allowed.
      def attribute(name, type = Object)
        attributes[name] = type

        define_method(name) do
          instance_variable_get("@#{name}")
        end
      end

      # @private
      def of_type?(type, value)
        (
          Array === type &&
          Array === value &&
          value.all? {|v| type[0] === v }
        ) || type === value
      end

      # @private
      def inherited(subclass)
        attributes.each do |name, type|
          subclass.attribute name, type
        end
      end
    end
  end
end
