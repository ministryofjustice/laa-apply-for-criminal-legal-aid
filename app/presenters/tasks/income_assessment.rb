module Tasks
  class IncomeAssessment < BaseTask
    def path
      edit_steps_income_employment_status_path
    end

    def not_applicable?
      applicant.present? && super
    end

    def can_start?
      fulfilled?(CaseDetails)
    end

    def in_progress?
      crime_application.income.present?
    end

    private

    def validator
      @validator ||= ::IncomeAssessment::AnswersValidator.new(
        record: crime_application.income,
        crime_application: crime_application
      )
    end
  end
end
