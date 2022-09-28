module Steps
  module Case
    class HearingDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :hearing_court_name, :string
      attribute :hearing_date, :multiparam_date

      validates :hearing_court_name, presence: true
      validates :hearing_date, presence: true,
                multiparam_date: { allow_past: false, allow_future: true }

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
