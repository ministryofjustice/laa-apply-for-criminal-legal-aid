module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_urn_path(crime_application)
    end

    def not_applicable?
      false
    end

    # Case details can start once the DWP check passes
    # TODO: update when we have the real check
    def can_start?
      crime_application.applicant&.nino.present?
    end

    # If we have a `case` record we consider this in progress
    def in_progress?
      crime_application.case.present?
    end

    # TODO: update when all case details steps are implemented
    def completed?
      false
    end
  end
end
