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

    # The last step of the applicant details task is the contact details
    # Only `correspondence_address_type` is mandatory, `telephone_number`
    # is not mandatory and can be left blank.
    #
    # Depending on the selected `correspondence_address_type`, we check
    # if the address record exists.
    #
    def completed?
      case applicant.correspondence_address_type
      when CorrespondenceType::HOME_ADDRESS.to_s
        applicant.home_address?
      when CorrespondenceType::OTHER_ADDRESS.to_s
        applicant.correspondence_address?
      when CorrespondenceType::PROVIDERS_OFFICE_ADDRESS.to_s
        true
      else
        false
      end
    end

    private

    def applicant
      @applicant ||= crime_application.applicant
    end
  end
end
