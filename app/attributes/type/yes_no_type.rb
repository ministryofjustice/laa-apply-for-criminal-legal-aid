module Type
  class YesNoType < ActiveModel::Type::String
    def cast(value)
      case value
      when String, Symbol
        YesNoAnswer.new(value)
      when YesNoAnswer
        value
      end
    end
  end
end
