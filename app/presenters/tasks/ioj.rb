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
      return true if ioj_passported?

      ioj.present? && ioj.types.any?
    end

    private

    def ioj_passported?
      Passporting::IojPassporter.new(crime_application).passported?
    end
  end
end
