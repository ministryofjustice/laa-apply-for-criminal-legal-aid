module PartnerEmploymentDetails
  class AnswersValidator
    include TypeOfMeansAssessment
    include TypeOfEmployment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :crime_application, to: :record

    def validate
      return unless applicable?

      errors.add :partner_employment_status, :incomplete if record.partner_employment_status.blank?

      validate_partner_employment
      validate_partner_self_employment

      errors.presence&.add(:base, :incomplete_records)
    end

    def applicable?
      requires_means_assessment? && include_partner_in_means_assessment?
    end

    # :nocov:
    def validate_partner_employment
      return unless income.partner_employed?

      validate_armed_forces
      validate_employment_details
      validate_employment_income
    end
    # :nocov:

    def validate_employment_details
      return unless requires_full_means_assessment?

      if record.partner_employments.blank? ||
         !record.partner_employments.all?(&:complete?)
        errors.add :employments, :incomplete
      end

      validate_self_assessment_tax_bill
      validate_other_work_benefit
    end

    def validate_self_assessment_tax_bill
      errors.add :partner_self_assessment_tax_bill, :incomplete if income.partner_self_assessment_tax_bill.blank?

      return unless income.partner_self_assessment_tax_bill == 'yes'

      if income.partner_self_assessment_tax_bill_amount.blank? ||
         income.partner_self_assessment_tax_bill_frequency.blank?
        errors.add :partner_self_assessment_tax_bill, :incomplete
      end
    end

    def validate_other_work_benefit
      errors.add :partner_other_work_benefit_received, :incomplete if income.partner_other_work_benefit_received.blank?

      return unless income.partner_other_work_benefit_received == 'yes'
      return if record.partner_work_benefits.present? && record.partner_work_benefits.complete?

      errors.add :partner_other_work_benefit_received, :incomplete
    end

    def validate_employment_income
      return if requires_full_means_assessment?

      errors.add :employment_income, :incomplete unless record.partner_employment_income&.complete?
    end

    def validate_partner_self_employment
      return unless income.partner_self_employed?

      errors.add(:businesses, :incomplete) if partner_businesses_incomplete?
      validate_self_assessment_tax_bill
      validate_other_work_benefit
    end

    def partner_businesses_incomplete?
      record.partner_businesses.blank? || !record.partner_businesses.all?(&:complete?)
    end

    def validate_armed_forces
      return unless record.require_partner_in_armed_forces?

      errors.add(:partner_in_armed_forces, :incomplete) if record.partner_in_armed_forces.blank?
    end

    alias income record
  end
end
