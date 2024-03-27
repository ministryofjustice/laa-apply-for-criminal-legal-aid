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

      cast(value * 0.01)
    end

    def serialize(value)
      serialize_cast_value(cast(value))
    end

    def serialize_cast_value(value)
      ensure_in_range(convert_to_pennies(cast(value)))
    end

    def cast(value)
      return if value.nil?
      return if value.is_a?(::String) && non_numeric_string?(value)

      format('%0.02f', convert_from_pennies(value))
    end

    private

    def convert_to_pennies(value)
      return if value.nil?
      return value if value.is_a? ::Integer

      (value.to_f * 100).to_i
    end

    def convert_from_pennies(value)
      return nil unless value
      return value unless value.is_a? ::Integer

      value * 0.01
    end
  end
end
