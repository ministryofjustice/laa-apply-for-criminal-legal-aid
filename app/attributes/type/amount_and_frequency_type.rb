module Type
  require 'dry-struct'

  # Similar to the ValueObject type but specifically for Amounts and Frequencies that are stored
  # as a jsonb column. Handles serialisation to and from json and structs.
  class AmountAndFrequencyType < ActiveRecord::Type::Value
    def type
      :amount_and_frequency
    end

    def cast(value)
      case value
      when String
        load_from_json(value)
      when Hash
        AmountAndFrequency.new(value)
      when AmountAndFrequency
        value
      when Dry::Struct
        AmountAndFrequency.new(value.attributes)
      end
    end

    def serialize(value)
      case value
      when Hash, AmountAndFrequency
        value.to_json
      else
        super
      end
    end

    def deserialize(value)
      load_from_json(value)
    end

    private

    def load_from_json(json_value)
      AmountAndFrequency.new JSON.parse(json_value)
    rescue StandardError
      AmountAndFrequency.new
    end
  end
end
