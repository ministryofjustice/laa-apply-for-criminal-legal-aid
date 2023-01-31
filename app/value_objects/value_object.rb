class ValueObject
  attr_reader :value

  delegate :to_s, :to_sym, to: :value

  def initialize(raw_value)
    raise ArgumentError, 'Raw value must be symbol or implicitly convertible' unless raw_value.respond_to?(:to_sym)

    @value = raw_value.to_sym
    freeze
  end

  def ==(other)
    other.is_a?(self.class) && other.value == value
  end
  alias === ==
  alias eql? ==

  def hash
    [ValueObject, self.class, value].hash
  end

  class << self
    # Define inquiry methods for each value in the value object,
    # i.e. `#coffee?` returns true for value `:coffee`, false for `:tea`
    def inherited(subclass)
      TracePoint.trace(:end) do |trace|
        # :nocov:
        if subclass == trace.self
          subclass.const_set(
            :INQUIRY_METHODS, subclass.values.map { |value| "#{value}?".to_sym }
          )

          subclass.values.each do |value|
            subclass.define_method("#{value}?") { value.eql?(self) }
          end
        end
        # :nocov:
      end

      super
    end

    def values
      const_defined?(:VALUES) ? self::VALUES : []
    end
  end
end
