module Type
  require 'dry-struct'

  class DateStampContextType < ActiveModel::Type::Value
    def type
      :jsonb
    end

    def cast_value(value)
      case value
      when String
        load_from_json(value)
      when Hash
        DateStampContext.new(value)
      when DateStampContext
        value
      when Dry::Struct
        DateStampContext.new(value.attributes)
      end
    end

    def serialize(value)
      case value
      when DateStampContext
        value.attributes.to_json
      else
        super
      end
    end

    def deserialize(value)
      load_from_json(value)
    end

    def load_from_json(json_value)
      DateStampContext.new JSON.parse(json_value)
    rescue StandardError
      DateStampContext.new
    end

    # DateStampContext once created cannot be changed, only deleted
    def changed_in_place?(_raw_old_value, _new_value)
      false
    end
  end
end
