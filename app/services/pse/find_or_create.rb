module Pse
  class FindOrCreate
    attr_reader :initial_application

    def initialize(initial_application:)
      @initial_application = initial_application
    end

    def call
      raise Errors::ApplicationCannotReceivePse unless initial_application.can_receive_pse?

      pse_application = CrimeApplication.find_by(usn:)

      return pse_application if pse_application

      CrimeApplication.create!(
        usn:, parent_id:, application_type:, office_code:, applicant:
      )
    end

    private

    def applicant
      @applicant ||= Applicant.new(
        first_name: initial_application.applicant.first_name,
        last_name: initial_application.applicant.last_name,
        other_names: initial_application.applicant.other_names,
        date_of_birth: initial_application.applicant.date_of_birth
      )
    end

    def application_type
      ApplicationType::POST_SUBMISSION_EVIDENCE
    end

    def office_code
      initial_application.provider_details&.office_code
    end

    def usn
      initial_application.reference
    end

    def parent_id
      initial_application.id
    end
  end
end
