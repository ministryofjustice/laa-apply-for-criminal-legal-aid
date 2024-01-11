module SubmissionSerializer
  class Application
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def generate
      to_builder.attributes!
    end

    def sections
      if crime_application.application_type == ApplicationType::POST_SUBMISSION_EVIDENCE.to_s
        [
          Sections::ApplicationDetails.new(crime_application),
          Sections::ProviderDetails.new(crime_application),
          Sections::ClientDetails.new(crime_application),
          Sections::PostSubmissionEvidence.new(crime_application),
        ].select(&:generate?)
      else
        [
          Sections::ApplicationDetails.new(crime_application),
          Sections::ProviderDetails.new(crime_application),
          Sections::ClientDetails.new(crime_application),
          Sections::CaseDetails.new(crime_application),
          Sections::IojDetails.new(crime_application),
          Sections::MeansDetails.new(crime_application),
          Sections::SupportingEvidence.new(crime_application),
          Sections::PostSubmissionEvidence.new(crime_application),
        ].select(&:generate?)
      end
    end

    private

    # :nocov:
    def to_builder
      Jbuilder.new do |json|
        sections.each do |section|
          json.merge! section.to_builder
        end
      end
    end
    # :nocov:
  end
end
