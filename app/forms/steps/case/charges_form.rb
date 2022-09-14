module Steps
  module Case
    class ChargesForm < Steps::BaseFormObject
      attribute :offence_name, :string

      delegate :offence_dates_attributes=, to: :record

      def offence_dates
        @offence_dates ||= record.offence_dates.map do |offence_date|
          OffenceDateFieldsetForm.build(
            offence_date, crime_application:
          )
        end
      end

      private

      def persist!
        record.update(
          attributes
        )
      end
    end
  end
end
