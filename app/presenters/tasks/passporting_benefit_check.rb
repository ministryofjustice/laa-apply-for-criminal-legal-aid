module Tasks
  class PassportingBenefitCheck < BaseTask
    def path
      edit_steps_dwp_benefit_type_path
    end

    def not_applicable?
      applicant&.under18? || crime_application.appeal_no_changes?
    end

    def can_start?
      fulfilled?(ClientDetails)
    end

    def in_progress?
      fulfilled?(ClientDetails)
    end

    def completed?
      crime_application.valid?(:passporting_benefit)
    end
  end
end
