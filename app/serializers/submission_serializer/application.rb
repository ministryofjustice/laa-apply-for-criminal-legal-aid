module SubmissionSerializer
  class Application
    attr_reader :crime_application

    delegate :application_type, to: :crime_application

    SECTIONS = {
      initial: %i[
        application_details
        provider_details
        client_details
        case_details
        ioj_details
        means_details
        supporting_evidence
      ],
      post_submission_evidence: %i[
        pse_application_details
        provider_details
        client_details
        supporting_evidence
      ]
    }.freeze

    def initialize(crime_application)
      @crime_application = crime_application
    end

    def generate
      to_builder.attributes!
    end

    def sections
      SECTIONS.fetch(application_type.to_sym).map do |section|
        Sections.const_get(section.to_s.camelize).new(crime_application)
      end.select(&:generate?)
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
