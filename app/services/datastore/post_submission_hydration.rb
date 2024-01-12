module Datastore
  class PostSubmissionHydration
    attr_reader :crime_application, :parent

    def initialize(crime_application, parent:)
      @crime_application = crime_application
      @parent = Adapters::JsonApplication.new(parent)
    end

    def call
      raise ApplicationNotInitial unless parent.initial?
      raise ApplicationNotAssessed unless parent.assessed?

      return if already_recreated?

      crime_application.update!(parent_id:, applicant:, application_type:)
    end

    private

    def parent_id
      parent.id
    end

    def applicant
      Applicant.new(parent.applicant.serializable_hash)
    end

    def application_type
      ApplicationType::POST_SUBMISSION_EVIDENCE
    end

    def already_recreated?
      crime_application.applicant.present?
    end
  end
end
