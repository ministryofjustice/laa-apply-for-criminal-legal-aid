module Tasks
  class Ioj < BaseTask
    def path
      if crime_application.ioj_passported?
        edit_steps_case_ioj_passport_path
      else
        edit_steps_case_ioj_path
      end
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
