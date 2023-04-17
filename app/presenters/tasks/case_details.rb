module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_urn_path
    end

    def not_applicable?
      false
    end

    def can_start?
      applicant.present? &&
        (applicant.under18? || applicant.passporting_benefit?)
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
