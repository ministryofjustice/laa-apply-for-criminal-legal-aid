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
      crime_application.case.ioj_passport.any? ||
        crime_application.case.ioj.present?
    end

    def completed?
      crime_application.case.ioj_passport.any? ||
        crime_application.case.ioj.types.any?
    end
  end
end
