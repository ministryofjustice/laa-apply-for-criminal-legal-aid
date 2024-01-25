module Summary
  class HtmlPresenter
    attr_reader :crime_application

    delegate :application_type, to: :crime_application

    SECTIONS = {
      initial: %i[
        overview
        client_details
        contact_details
        case_details
        offences
        codefendants
        next_court_hearing
        first_court_hearing
        justification_for_legal_aid
        passport_justification_for_legal_aid
        employment_details
        income_details
        other_income_details
        housing_payments
        other_outgoings_details
        supporting_evidence
        legal_representative_details
      ],
      post_submission_evidence: %i[
        overview
        client_details
        supporting_evidence
        legal_representative_details
      ]
    }.freeze

    def initialize(crime_application:)
      @crime_application = Adapters::BaseApplication.build(crime_application)
    end

    def sections
      SECTIONS.fetch(application_type.to_sym).map do |section|
        Sections.const_get(section.to_s.camelize).new(crime_application)
      end.select(&:show?)
    end
  end
end
