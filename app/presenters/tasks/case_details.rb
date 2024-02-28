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
      crime_application.case.complete?
    end
  end
end
