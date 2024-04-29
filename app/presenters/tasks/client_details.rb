module Tasks
  class ClientDetails < BaseTask
    def path
      edit_steps_client_details_path
    end

    def not_applicable?
      false
    end

    # Client details is the first thing a provider can do so it is always true
    def can_start?
      true
    end

    # If we have an `applicant` record we consider this in progress
    def in_progress?
      applicant.present?
    end

    def completed?
      crime_application.valid?(:client_details)
    end
  end
end
