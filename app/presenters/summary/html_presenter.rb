module Summary
  class HtmlPresenter # rubocop:disable Metrics/ClassLength
    attr_reader :crime_application

    delegate :application_type, :appeal_no_changes?, to: :crime_application

    SECTIONS = {
      initial: %i[
        overview
        client_details
        contact_details
        passporting_benefit_check
        case_details
        offences
        codefendants
        next_court_hearing
        first_court_hearing
        justification_for_legal_aid
        passport_justification_for_legal_aid
        employment_details
        income_details
        income_payments_details
        income_benefits_details
        dependants
        other_income_details
        housing_payments
        outgoings_payments_details
        other_outgoings_details
        properties
        savings
        premium_bonds
        national_savings_certificates
        investments
        trust_fund
        other_capital_details
        supporting_evidence
        more_information
        legal_representative_details
      ],
      post_submission_evidence: %i[
        overview
        client_details
        supporting_evidence
        more_information
        legal_representative_details
      ],
      appeal_with_no_changes: %i[
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
        supporting_evidence
        more_information
        legal_representative_details
      ],
      capital: %i[
        properties
        savings
        premium_bonds
        national_savings_certificates
        investments
        trust_fund
        other_capital_details
      ],
      outgoings: %i[
        housing_payments
        outgoings_payments_details
        other_outgoings_details
      ],
      income: %i[
        employment_details
        income_details
        income_payments_details
        income_benefits_details
        dependants
        other_income_details
      ]
    }.freeze

    def initialize(crime_application:)
      @crime_application = Adapters::BaseApplication.build(crime_application)
    end

    def sections
      if appeal_no_changes?
        build_sections(:appeal_with_no_changes)
      else
        build_sections(application_type.to_sym)
      end
    end

    def income_sections
      build_sections(:income)
    end

    def outgoings_sections
      build_sections(:outgoings)
    end

    def capital_sections
      build_sections(:capital)
    end

    private

    def build_sections(relevant_sections)
      SECTIONS.fetch(relevant_sections).map do |section|
        Sections.const_get(section.to_s.camelize).new(crime_application)
      end.select(&:show?)
    end
  end
end
