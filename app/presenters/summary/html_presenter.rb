module Summary
  class HtmlPresenter
    attr_reader :crime_application

    def initialize(crime_application:)
      @crime_application = crime_application
    end

    def sections
      [
        Sections::ClientDetails.new(crime_application),
        Sections::ContactDetails.new(crime_application),
      ].select(&:show?)
    end
  end
end
