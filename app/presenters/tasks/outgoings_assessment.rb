module Tasks
  class OutgoingsAssessment < BaseTask
    include TypeOfMeansAssessment

    def path
      edit_steps_outgoings_housing_payment_type_path
    end

    def not_applicable?
      return false unless fulfilled?(IncomeAssessment)

      !requires_full_means_assessment?
    end

    def can_start?
      fulfilled?(IncomeAssessment) && requires_full_means_assessment?
    end

    def in_progress?
      outgoings.present?
    end

    def completed?
      outgoings.complete?
    end
  end
end
