module Tasks
  class ClientDetails < BaseTask
    def path
      edit_steps_client_details_path
    end

    # Client details is the first thing a provider can do so it is always true
    def can_start?
      true
    end

    # If we have an `applicant` record we consider this in progress
    def in_progress?
      applicant.present?
    end

    private

    def validator
      @validator ||= ::ClientDetails::AnswersValidator.new(
        record:, crime_application:
      )
    end

    alias record crime_application
  end
end
