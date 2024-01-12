module SubmissionSerializer
  class PostSubmissionEvidence < Application
    def sections
      [
        Sections::ApplicationDetails.new(crime_application),
        Sections::ProviderDetails.new(crime_application),
        Sections::ClientDetails.new(crime_application),
        Sections::PostSubmissionEvidence.new(crime_application),
      ].select(&:generate?)
    end
  end
end
