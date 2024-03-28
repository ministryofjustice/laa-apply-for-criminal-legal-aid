module Type
  # Assumes if set with an Integer value it must already be pence
  # Consider situations where form input fields auto-convert string values
  # to Integer rather than Float which could cause invalid values to be persisted
  class Pence < ActiveRecord::Type::BigInteger
    def type
      :pence
    end

    def deserialize(value)
      return if value.nil?

      Money.new(value)
    end

    def serialize(value)
      serialize_cast_value(cast(value))
    end

    def serialize_cast_value(value)
      return if value.nil?

      ensure_in_range(value.to_i)
    end

    def cast(value)
      return if value.nil?
      return if value.is_a?(::String) && non_numeric_string?(value)
      return value if value.is_a?(::Money)

      Money.new(value_in_pence(value))
    end

    private

    def value_in_pence(value)
      return value if value.is_a?(::Integer)

      (value.to_f * 100).to_i
    end
  end
end
