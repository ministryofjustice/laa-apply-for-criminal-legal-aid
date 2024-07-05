module Steps
  module Income
    class BusinessStartDateForm < Steps::BaseFormObject
      attribute :trading_start_date, :multiparam_date
      validates :trading_start_date, presence: true, multiparam_date: { earliest_year: 1000 }

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end
    end
  end
end
