module Summary
  class HtmlPresenter
    attr_reader :crime_application

    def initialize(crime_application:)
      @crime_application = Adapters::BaseApplication.build(crime_application)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def sections
      [
        Sections::Overview.new(crime_application),
        Sections::ClientDetails.new(crime_application),
        Sections::ContactDetails.new(crime_application),
        Sections::CaseDetails.new(crime_application),
        Sections::Offences.new(crime_application),
        Sections::Codefendants.new(crime_application),
        Sections::NextCourtHearing.new(crime_application),
        Sections::FirstCourtHearing.new(crime_application),
        Sections::JustificationForLegalAid.new(crime_application),
        Sections::PassportJustificationForLegalAid.new(crime_application),
        Sections::EmploymentDetails.new(crime_application),
        Sections::IncomeDetails.new(crime_application),
        Sections::OtherIncomeDetails.new(crime_application),
        Sections::SupportingEvidence.new(crime_application),
        Sections::LegalRepresentativeDetails.new(crime_application),
      ].select(&:show?)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
