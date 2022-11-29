module SubmissionSerializer
  class Application
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # TODO: For now we will skip this until we have provider details included fully
    # :nocov:
    def generate
      to_builder.attributes!
    end
    # :nocov:

    def sections
      [
        Sections::ApplicationDetails.new(crime_application),
        Sections::ProviderDetails.new(crime_application),
        Sections::ClientDetails.new(crime_application),
        Sections::CaseDetails.new(crime_application),
        Sections::IojDetails.new(crime_application),
      ].select(&:generate?)
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
