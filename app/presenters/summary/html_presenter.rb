module Summary
  class HtmlPresenter
    attr_reader :crime_application

    def initialize(crime_application:)
      @crime_application = Adapters::BaseApplication.build(crime_application)
    end

    def sections
      [
        Sections::ClientDetails.new(crime_application),
        Sections::ContactDetails.new(crime_application),
        Sections::CaseDetails.new(crime_application),
        Sections::Offences.new(crime_application),
        Sections::Codefendants.new(crime_application),
        Sections::NextCourtHearing.new(crime_application),
        Sections::JustificationForLegalAid.new(crime_application),
        Sections::PassportJustificationForLegalAid.new(crime_application),
      ].select(&:show?)
    end
  end
end
