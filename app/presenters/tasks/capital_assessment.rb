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
      fulfilled?(IncomeAssessment) && requires_full_means_assessment?
    end

    def in_progress?
      capital.present?
    end

    private

    def validator
      @validator ||= ::CapitalAssessment::AnswersValidator.new(crime_application)
    end
  end
end
