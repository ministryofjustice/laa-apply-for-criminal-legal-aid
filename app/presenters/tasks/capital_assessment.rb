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
      return false unless fulfilled?(ClientDetails)
      return true unless requires_means_assessment?
      return false unless fulfilled?(IncomeAssessment)

      !requires_full_means_assessment?
    end

    def can_start?
      fulfilled?(IncomeAssessment) && requires_full_means_assessment?
    end

    delegate :capital, to: :crime_application

    def in_progress?
      capital.present?
    end

    def completed?
      capital.complete?
    end
  end
end
