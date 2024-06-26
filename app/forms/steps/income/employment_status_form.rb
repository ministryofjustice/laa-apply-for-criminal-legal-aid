module Steps
  module Income
    class EmploymentStatusForm < Steps::BaseFormObject
      include TypeOfEmployment
      include Steps::HasOneAssociation

      has_one_association :income

      attribute :employment_status, array: true, default: []
      attribute :ended_employment_within_three_months, :value_object, source: YesNoAnswer

      validates_inclusion_of :ended_employment_within_three_months,
                             in: :yes_no_choices,
                             presence: true,
                             if: -> { not_working? }

      validate :validate_statuses

      def employment_status=(ary)
        super(ary.compact_blank) if ary
      end

      def choices
        EmploymentStatus.values
      end

      def yes_no_choices
        YesNoAnswer.values
      end

      private

      def validate_statuses
        return unless employment_status.empty? || (employment_status - choices.map(&:to_s)).any?

        errors.add(:employment_status,
                   :invalid)
      end

      def persist!
        if employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
          ::Income.transaction do
            reset_employments!
          end
        end

        income.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'ended_employment_within_three_months' => (ended_employment_within_three_months if not_working?)
        }
      end

      def reset_employments!
        crime_application.client_employments&.destroy_all
        crime_application.income.reset_client_employment_fields!
        crime_application.applicant.income_payments.employment&.destroy!
        crime_application.applicant.income_payments.work_benefits&.destroy!
      end
    end
  end
end
