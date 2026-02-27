module EmploymentDetails
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

      errors.add :employment_status, :incomplete if record.employment_status.blank?
      errors.add :employment_status, :incomplete unless not_working_details_complete?

      validate_client_employment
      validate_client_self_employment

      errors.presence&.add(:base, :incomplete_records)
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
    def validate_client_employment
      return unless employed?

      validate_armed_forces
      validate_employment_details
      validate_employment_income
    end
    # :nocov:

    def validate_employment_details
      return unless requires_full_means_assessment?

      errors.add(:employments, :incomplete) if record.employments.blank? || !record.employments.all?(&:complete?)

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
      return if income.client_work_benefits.present? && income.client_work_benefits.complete?

      errors.add :applicant_other_work_benefit_received, :incomplete
    end

    def validate_employment_income
      return if requires_full_means_assessment?

      errors.add :employment_income, :incomplete unless record.client_employment_income&.complete?
    end

    def validate_client_self_employment
      return unless income.client_self_employed?

      errors.add(:businesses, :incomplete) if client_businesses_incomplete?
      validate_self_assessment_tax_bill
      validate_other_work_benefit
    end

    def client_businesses_incomplete?
      record.client_businesses.blank? || !record.client_businesses.all?(&:complete?)
    end

    def validate_armed_forces
      return unless record.require_client_in_armed_forces?

      errors.add(:client_in_armed_forces, :incomplete) if record.client_in_armed_forces.blank?
    end

    alias income record
  end
end
