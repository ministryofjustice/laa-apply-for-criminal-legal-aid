module Type
  class CorrespondenceAddressType < ActiveModel::Type::String
    def cast(value)
      case value
      when String, Symbol
        CorrespondenceTypeAnswer.new(value)
      when CorrespondenceTypeAnswer
        value
      end
    end
  end
end
