module EmploymentDetails
  class AnswersValidator
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    include TypeOfMeansAssessment
    include TypeOfEmployment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :crime_application, to: :record

    def validate
      return unless applicable?

      errors.add :employment_status, :incomplete if record.employment_status.blank?
      errors.add :employment_status, :incomplete unless not_working_details_complete?

      validate_employment
      validate_partner_employment

      errors.add :base, :incomplete_records if errors.present?
    end

    def validate_partner_employment
      return unless include_partner_in_means_assessment?

      errors.add :partner_employment_status, :incomplete if record.partner_employment_status.blank?
    end

    def applicable?
      requires_means_assessment?
    end

    def not_working_details_complete?
      return true unless not_working?
      return false if income.ended_employment_within_three_months.blank?
      return true unless ended_employment_within_three_months?
      return true if income.lost_job_in_custody == 'no'

      income.date_job_lost.present?
    end

    # :nocov:
    def validate_employment
      return unless employed?

      validate_employment_details
      validate_employment_income
    end
    # :nocov:

    def validate_employment_details
      return unless requires_full_means_assessment?

      if record.crime_application.employments.blank? || !record.crime_application.employments.all?(&:complete?)
        errors.add :employments, :incomplete
      end

      validate_self_assessment_tax_bill
      validate_other_work_benefit
    end

    def validate_self_assessment_tax_bill
      errors.add :applicant_self_assessment_tax_bill, :incomplete if income.applicant_self_assessment_tax_bill.blank?

      return unless income.applicant_self_assessment_tax_bill == 'yes'

      if income.applicant_self_assessment_tax_bill_amount.blank? ||
         income.applicant_self_assessment_tax_bill_frequency.blank?
        errors.add :applicant_self_assessment_tax_bill, :incomplete
      end
    end

    def validate_other_work_benefit
      if income.applicant_other_work_benefit_received.blank?
        errors.add :applicant_other_work_benefit_received, :incomplete
      end

      return unless income.applicant_other_work_benefit_received == 'yes'
      return if record.income_payments&.work_benefits.present? && record.income_payments&.work_benefits&.complete?

      errors.add :applicant_other_work_benefit_received, :incomplete
    end

    def validate_employment_income
      return if requires_full_means_assessment?

      errors.add :employment_income, :incomplete unless record.income_payments&.employment&.complete?
    end

    alias income record
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  end
end
