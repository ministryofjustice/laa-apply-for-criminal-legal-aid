module Tasks
  class IncomeAssessment < BaseTask
    include TypeOfMeansAssessment

    def path
      edit_steps_income_employment_status_path
    end

    def not_applicable?
      applicant && super
    end

    def can_start?
      fulfilled?(CaseDetails) && requires_means_assessment?
    end

    def in_progress?
      income.present?
    end

    private

    def validator
      @validator ||= ::IncomeAssessment::AnswersValidator.new(crime_application)
    end
  end
end
