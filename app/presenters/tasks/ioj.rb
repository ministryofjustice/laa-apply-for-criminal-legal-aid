module Tasks
  class Ioj < BaseTask
    def path
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
      crime_application.ioj_passported? || ioj.present?
    end

    private

    def validator
      @validator ||= InterestsOfJustice::AnswersValidator.new(crime_application)
    end
  end
end
