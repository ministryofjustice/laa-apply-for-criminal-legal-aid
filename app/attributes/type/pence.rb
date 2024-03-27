module Type
  # Assumes if set with an Integer value it must already be pence
  # Consider situations where form input fields auto-convert string values
  # to Integer rather than Float which could cause invalid values to be persisted
  class Pence < ActiveRecord::Type::Integer
    def type
      :pence
    end

    def deserialize(value)
      return if value.blank?

      cast(value * 0.01)
    end

    def serialize(value)
      return if value.nil?
      return if value.is_a?(::String) && non_numeric_string?(value)
      return super if value.is_a?(Integer)

      super((value.to_f * 100).to_i)
    end

    def cast(value)
      return format('%0.02f', value) if value.is_a? Float

      value
    end
  end
end
