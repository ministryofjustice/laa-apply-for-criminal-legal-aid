module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_client_case_type_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(ClientDetails)
    end

    # If we have a `case` record we consider this in progress
    def in_progress?
      crime_application.case.present?
    end

    def completed?
      crime_application.case.values_at(
        :hearing_court_name, :hearing_date
      ).all?(&:present?) &&
        crime_application.case.case_concluded_attributes_present? &&
        crime_application.case.client_remanded_attributes_present? &&
        crime_application.case.preorder_work_attributes_present?
    end
  end
end
