module Tasks
  class ClientDetails < BaseTask
    def path
      '/steps/client/details'
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
      crime_application.applicant.present?
    end

    # The last step of the applicant details task is the contact details
    #
    # NOTE: might be refined for the scenario the correspondence type
    # is `other_address` but there is no `CorrespondenceAddress` record
    def completed?
      crime_application.applicant&.correspondence_address_type.present?
    end
  end
end
