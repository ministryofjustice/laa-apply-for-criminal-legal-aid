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
      return if complete?

      errors.add :employment_status, :incomplete
      errors.add :base, :incomplete_records
    end

    def applicable?
      requires_means_assessment?
    end

    def complete?
      return false if record.employment_status.blank?
      return false if include_partner_in_means_assessment? && record.partner_employment_status.blank?

      not_working_details_complete?
    end

    def not_working_details_complete?
      return true unless not_working?
      return false if income.ended_employment_within_three_months.blank?
      return true unless ended_employment_within_three_months?
      return true if income.lost_job_in_custody == 'no'

      income.date_job_lost.present?
    end

    alias income record
  end
end
