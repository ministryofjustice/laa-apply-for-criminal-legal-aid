module Steps
  module Case
    class HearingDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :hearing_court_name, :string
      attribute :hearing_date, :multiparam_date
      attribute :is_first_court_hearing, :value_object, source: FirstHearingAnswer

      validates :hearing_court_name, presence: true
      validates :hearing_date, presence: true,
                multiparam_date: { allow_future: true }

      validates :is_first_court_hearing, inclusion: { in: :choices }

      def choices
        FirstHearingAnswer.values
      end

      private

      def persist!
        kase.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            attributes_to_reset
          )
        )
      end

      def attributes_to_reset
        return {} if is_first_court_hearing.no?

        {
          first_court_hearing_name: nil,
        }
      end
    end
  end
end
