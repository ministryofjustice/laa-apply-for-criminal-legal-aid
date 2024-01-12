module SubmissionSerializer
  class Application
    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def generate
      to_builder.attributes!
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
