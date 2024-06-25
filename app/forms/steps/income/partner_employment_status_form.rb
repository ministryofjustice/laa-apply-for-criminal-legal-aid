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
        income.update(attributes)
      end

      # def not_working?
      #   employment_status&.include?(EmploymentStatus::NOT_WORKING.to_s)
      # end

      def before_save
        return true unless not_working?

        crime_application.partner_employments&.destroy!
        crime_application.income.reset_partner_employment_fields!
        crime_application.income_payments.for_partner.employment&.destroy!
      end
    end
  end
end
