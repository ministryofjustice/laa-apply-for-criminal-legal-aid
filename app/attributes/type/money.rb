module Type
  class Money < ActiveRecord::Type::Integer
    def type
      :money
    end

    def deserialize(value)
      return if value.blank?

      super.to_f / 100
    end

    def serialize(value)
      super (value.to_f * 100).round
    end

    def cast(value)
      return format('%0.02f', value) if value.is_a? Float

      value
    end
  end
end
