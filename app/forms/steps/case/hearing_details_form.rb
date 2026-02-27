module Steps
  module Case
    class HearingDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :hearing_court_name, :string
      attribute :hearing_date, :multiparam_date
      attribute :is_first_court_hearing, :value_object, source: FirstHearingAnswer

      validates :hearing_court_name, presence: true
      # hearing_date must fall between 01/01/2010 - 31/12/2035 as per validation in MAAT; latest update LASB-3572
      validates :hearing_date, presence: true,
                multiparam_date: { allow_future: true,
                                   earliest_year: ::Case::EARLIEST_HEARING_DATE.year,
                                   latest_year: ::Case::LATEST_HEARING_DATE.year }

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
