module Evidence
  module Rules
    class NationalInsuranceNumber < Rule
      include Evidence::RuleDsl

      key :national_insurance_32
      group :none

      client do |crime_application|
        NinoRequired.new(crime_application).for_applicant?
      end

      partner do |crime_application|
        NinoRequired.new(crime_application).for_partner?
      end
    end
  end

  class NinoRequired
    include TypeOfMeansAssessment

    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application
    end

    # Using existing CrimeApplication#applicant_requires_nino_evidence? 
    # method for now to avoid regression.
    def for_applicant?
      return false unless applicant.present?
      return false unless applicant.over_18_at_date_stamp? && applicant.nino.blank?
      return true if benefit_check_recipient.applicant? && nino_forthcoming?
      return true if indictable_or_in_crown_court?

      income_benefit_ownerships.include?(OwnershipType::APPLICANT.to_s)
    end

    def for_partner?
      return false unless include_partner_in_means_assessment?
      return false unless partner.over_18_at_date_stamp? && partner.nino.blank?
      return true if benefit_check_recipient.partner? && nino_forthcoming?

      income_benefit_ownerships.include?(OwnershipType::PARTNER.to_s)
    end

    private

    def income_benefit_ownerships
      @income_benefit_ownerships ||= crime_application.income_benefits.pluck(:ownership_type)
    end

    def indictable_or_in_crown_court?
      [ 
        CaseType::INDICTABLE.to_s, CaseType::ALREADY_IN_CROWN_COURT.to_s
      ].include? kase&.case_type
    end
  end
end
