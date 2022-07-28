module Type
  class MultiparamDate < ActiveModel::Type::Date
    # Used to coerce a Rails multi parameter date into a standard date,
    # with some light validation to not end up with wrong dates or
    # raising exceptions. Additional validation is performed in the
    # form object through the validators.
    #
    def cast(value)
      return value if value.blank? || value.is_a?(Date)

      # `value` is a hash in the format: {3=>31, 2=>12, 1=>2000}
      # where `3` is the day, `2` is the month and `1` is the year.
      value_args = value.values_at(1, 2, 3)

      if Date.valid_date?(*value_args)
        Date.new(*value_args)
      else
        # This is not a valid date, but we return the hash so we perform
        # more granular validation in the form object and can render the
        # view with the errors and whatever values the user entered.
        value
      end
    end

    # Override superclass behavior as it will blindly try to build
    # a date, which will blow up with wrong data (like day=32 or month=13).
    # Leave the sanity check to the `#cast` method.
    def value_from_multiparameter_assignment(value)
      value
    end
  end
end
