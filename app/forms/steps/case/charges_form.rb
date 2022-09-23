module Steps
  module Case
    class ChargesForm < Steps::BaseFormObject
      attribute :offence_name, :string
      validates :offence_name, presence: true

      delegate :offence_dates_attributes=, to: :record

      validates_with ChargesValidator, unless: :any_marked_for_destruction?

      def offence_dates
        @offence_dates ||= record.offence_dates.map do |offence_date|
          OffenceDateFieldsetForm.build(
            offence_date, crime_application:
          )
        end
      end

      def any_marked_for_destruction?
        offence_dates.any?(&:_destroy)
      end

      def show_destroy?
        offence_dates.size > 1
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
