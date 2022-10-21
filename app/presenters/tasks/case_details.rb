module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_urn_path
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

    def completed?
      crime_application.case.values_at(
        :hearing_court_name, :hearing_date
      ).all?(&:present?)
    end
  end
end
