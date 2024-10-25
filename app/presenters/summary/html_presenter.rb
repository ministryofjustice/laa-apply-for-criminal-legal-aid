module Summary
  class HtmlPresenter # rubocop:disable Metrics/ClassLength
    attr_reader :crime_application

    delegate :application_type, :appeal_no_changes?, to: :crime_application

    SECTIONS = {
      initial: %i[
        overview
        client_details
        date_stamp_context
        contact_details
        partner_details
        passporting_benefit_check
        passporting_benefit_check_partner
        case_details
        offences
        codefendants
        client_other_charge
        partner_other_charge
        next_court_hearing
        first_court_hearing
        justification_for_legal_aid
        passport_justification_for_legal_aid
        employment_details
        employment_income
        income_details
        client_employments
        client_businesses
        self_assessment_tax_bill
        work_benefits
        income_payments_details
        income_benefits_details
        dependants
        partner_employment_details
        partner_employment_income
        partner_employments
        partner_businesses
        partner_self_assessment_tax_bill
        partner_work_benefits
        partner_income_payments_details
        partner_income_benefits_details
        other_income_details
        housing_payments
        outgoings_payments_details
        other_outgoings_details
        properties
        savings
        premium_bonds
        partner_premium_bonds
        national_savings_certificates
        investments
        trust_fund
        partner_trust_fund
        other_capital_details
        supporting_evidence
        more_information
        declarations
        funding_decisions
        legal_representative_details
      ],
      change_in_financial_circumstances: %i[
        overview
        client_details
        date_stamp_context
        contact_details
        partner_details
        passporting_benefit_check
        passporting_benefit_check_partner
        case_details
        offences
        codefendants
        client_other_charge
        partner_other_charge
        next_court_hearing
        first_court_hearing
        justification_for_legal_aid
        passport_justification_for_legal_aid
        employment_details
        employment_income
        income_details
        client_employments
        client_businesses
        self_assessment_tax_bill
        work_benefits
        income_payments_details
        income_benefits_details
        dependants
        partner_employment_details
        partner_employment_income
        partner_employments
        partner_businesses
        partner_self_assessment_tax_bill
        partner_work_benefits
        partner_income_payments_details
        partner_income_benefits_details
        other_income_details
        housing_payments
        outgoings_payments_details
        other_outgoings_details
        properties
        savings
        premium_bonds
        partner_premium_bonds
        national_savings_certificates
        investments
        trust_fund
        partner_trust_fund
        other_capital_details
        supporting_evidence
        more_information
        declarations
        legal_representative_details
      ],
      post_submission_evidence: %i[
        overview
        client_details
        supporting_evidence
        more_information
        legal_representative_details
      ],
      capital: %i[
        properties
        savings
        premium_bonds
        partner_premium_bonds
        national_savings_certificates
        investments
        trust_fund
        partner_trust_fund
        other_capital_details
      ],
      outgoings: %i[
        housing_payments
        outgoings_payments_details
        other_outgoings_details
      ],
      income: %i[
        employment_details
        employment_income
        income_details
        client_employments
        client_businesses
        self_assessment_tax_bill
        work_benefits
        income_payments_details
        income_benefits_details
        dependants
      ],
      partner_income: %i[
        partner_employment_details
        partner_employment_income
        partner_employments
        partner_businesses
        partner_self_assessment_tax_bill
        partner_work_benefits
        partner_income_payments_details
        partner_income_benefits_details
      ],
      other_income: %i[
        other_income_details
      ]
    }.freeze

    def initialize(crime_application:)
      @crime_application = Adapters::BaseApplication.build(crime_application)
    end

    def sections
      build_sections(application_type.to_sym)
    end

    def income_sections
      build_sections(:income)
    end

    def partner_income_sections
      build_sections(:partner_income)
    end

    def other_income_sections
      build_sections(:other_income)
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
