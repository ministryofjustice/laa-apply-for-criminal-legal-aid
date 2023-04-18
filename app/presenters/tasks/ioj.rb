module Tasks
  class Ioj < BaseTask
    def path
      edit_steps_case_ioj_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(CaseDetails)
    end

    def in_progress?
      crime_application.ioj_passport.any? || ioj.present?
    end

    def completed?
      return true if crime_application.ioj_passported?

      ioj.present? && ioj.types.any?
    end
  end
end
