module Type
  class MultiparamDate < ActiveModel::Type::Date
    # Used to coerce a Rails multi parameter date into a standard date,
    # with some light validation to not end up with wrong dates or
    # raising exceptions. Additional validation is performed in the
    # form object through the validators.
    #
    def cast(value)
      return value if value.blank? || value.is_a?(Date)

      # `value` is a hash in the format: {3=>31, 2=>'12', 1=>2000}
      # where `3` is the day, `2` is the month (digit or month name) and `1` is the year.
      value_args = normalize_month_of_date(value).values_at(1, 2, 3)

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

    private

    # Attempt to parse the month, which could be a digit or a month name
    # Assumes value[2] to be the month value
    def normalize_month_of_date(value)
      normalized = value.dup
      month_value = value[2]

      begin
        normalized[2] = month_value.to_i.nonzero? || parse_month(month_value)
        normalized
      rescue StandardError
        value
      end
    end

    # Parse a full or abbreviated month name
    # Relies on the correct locale being set when the value is non-English
    def parse_month(month)
      I18n.t('date.month_names').index(month.capitalize) || I18n.t('date.abbr_month_names').index(month.capitalize) || 0
    end
  end
end
