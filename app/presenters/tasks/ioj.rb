module Tasks
  class Ioj < BaseTask
    def path
      return edit_steps_case_ioj_path if crime_application.slipstream_audit_ioj_required?

      if crime_application.ioj_passported?
        edit_steps_case_ioj_passport_path
      else
        edit_steps_case_ioj_path
      end
    end

    def can_start?
      fulfilled?(CaseDetails)
    end

    def in_progress?
      crime_application.slipstream_audit_ioj_required? || crime_application.ioj_passported? || ioj.present?
    end

    private

    def validator
      @validator ||= InterestsOfJustice::AnswersValidator.new(crime_application)
    end
  end
end
