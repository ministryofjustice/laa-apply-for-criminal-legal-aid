module Tasks
  class IncomeAssessment < BaseTask
    include TypeOfMeansAssessment

    def path
      edit_steps_income_employment_status_path
    end

    def not_applicable?
      return false unless fulfilled?(ClientDetails)

      !requires_means_assessment?
    end

    def can_start?
      fulfilled?(CaseDetails) && requires_means_assessment?
    end

    def in_progress?
      income.present?
    end

    def completed?
      income.complete?
    end
  end
end
