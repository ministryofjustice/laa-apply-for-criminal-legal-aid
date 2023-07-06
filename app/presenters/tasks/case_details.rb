module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_case_type_path
    end

    def not_applicable?
      false
    end

    def can_start?
      applicant.present? && crime_application.means_passported?
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
