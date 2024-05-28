module Tasks
  class CapitalAssessment < BaseTask
    include TypeOfMeansAssessment

    def path
      if requires_full_capital?
        edit_steps_capital_property_type_path
      else
        edit_steps_capital_trust_fund_path
      end
    end

    def not_applicable?
      applicant.present? && super
    end

    def can_start?
      fulfilled?(IncomeAssessment)
    end

    def in_progress?
      capital.present?
    end

    # Capital task is only complete when both the AnswersValidator
    # AND the ConfirmationValidators are complete
    def completed?
      super && capital.complete?
    end

    private

    def validator
      @validator ||= ::CapitalAssessment::AnswersValidator.new(
        record: capital,
        crime_application: crime_application
      )
    end
  end
end
