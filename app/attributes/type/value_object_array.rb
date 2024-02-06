module Type
  class ValueObjectArray < ActiveModel::Type::Value
    attr_reader :source

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      super
    end

    def type
      :value_object_array
    end

    def serialize(value)
      value.to_s
    end

    def ==(other)
      self.class == other.class && source == other.source
    end
    alias eql? ==

    def hash
      [self.class, source].hash
    end

    private

    def cast_value(value)
      if value.is_a?(Array)
        value
      elsif value.is_a?(String)
        value.split(',')
      else
        []
      end
    end

    def deserialize(value)
      PG::TextDecoder::Array.new.decode(value).map { |v| Currency.string_to_currency(v) }
    end

    def serialize(value)
      PG::TextEncoder::Array.new.encode(value)
    end
  end
end

class CurrencyType < ActiveRecord::Type::Value
  def type
    :string
  end

  def cast(value)
    value.map { |v| Currency.string_to_currency(v) }
  end
end
