module SubmissionSerializer
  class Initial
    def sections
      [
        Sections::ApplicationDetails.new(crime_application),
        Sections::ProviderDetails.new(crime_application),
        Sections::ClientDetails.new(crime_application),
        Sections::CaseDetails.new(crime_application),
        Sections::IojDetails.new(crime_application),
        Sections::MeansDetails.new(crime_application),
        Sections::SupportingEvidence.new(crime_application),
      ].select(&:generate?)
    end
  end
end
