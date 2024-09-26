module Steps
  module Case
    class OtherChargeForm < Steps::BaseFormObject
      attribute :charge, :string
      attribute :hearing_court_name, :string
      attribute :next_hearing_date, :multiparam_date

      validates :next_hearing_date, multiparam_date: { allow_future: true }

      def persist!
        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end
    end
  end
end
