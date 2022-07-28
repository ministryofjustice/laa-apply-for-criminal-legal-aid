module Type
  class StrippedString < ActiveModel::Type::String
    # Remove leading and trailing spaces from strings, as these
    # are usually obtained from input text and users can copy&paste
    # introducing extraneous spaces without noticing.
    def cast(value)
      value.is_a?(String) ? super(value.strip) : super
    end
  end
end
