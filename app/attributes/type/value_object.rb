module Type
  class ValueObject < ActiveModel::Type::Value
    attr_reader :source

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      super
    end

    def type
      :value_object
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
      case value
      when String, Symbol
        source.new(value)
      when source
        value
      end
    end
  end
end
