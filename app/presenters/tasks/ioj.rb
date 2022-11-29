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
      crime_application.ioj_passport.any? ||
        crime_application.ioj.present?
    end

    def completed?
      crime_application.ioj_passport.any? ||
        crime_application.ioj.types.any?
    end
  end
end
