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
      [
        Sections::ApplicationDetails.new(crime_application),
        Sections::ProviderDetails.new(crime_application),
        Sections::ClientDetails.new(crime_application),
      ].select(&:generate?)
    end

    private

    def to_builder
      Jbuilder.new do |json|
        sections.each do |section|
          json.merge! section.to_builder
        end
      end
    end
  end
end
