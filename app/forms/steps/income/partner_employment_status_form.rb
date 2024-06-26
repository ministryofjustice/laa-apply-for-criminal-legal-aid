module Steps
  module Income
    class PartnerEmploymentStatusForm < Steps::BaseFormObject
      include TypeOfEmployment
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :partner_employment_status, array: true, default: []

      validate :validate_statuses

      def partner_employment_status=(ary)
        super(ary.compact_blank) if ary
      end

      def choices
        EmploymentStatus.values
      end

      private

      def validate_statuses
        return unless partner_employment_status.empty? || (partner_employment_status - choices.map(&:to_s)).any?

        errors.add(:partner_employment_status,
                   :invalid)
      end

      def persist!
        # :nocov:
        if partner_employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
          ::Income.transaction do
            reset_employments!
          end
        end
        # :nocov:

        income.update(attributes)
      end

      # TODO: Improve coverage
      # :nocov:
      def reset_employments!
        crime_application.partner_employments&.destroy_all
        crime_application.income.reset_partner_employment_fields!
        crime_application.partner.income_payments.employment&.destroy!
        crime_application.partner.income_payments.work_benefits&.destroy!
      end
      # :nocov:
    end
  end
end
