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
      return true if ioj_passported?

      crime_application.ioj.present? &&
        crime_application.ioj.types.any?
    end

    private

    def ioj_passported?
      IojPassporter.new(crime_application).call
    end
  end
end
