module Evidence
  module Rules
    class NationalInsuranceNumber < Rule
      include Evidence::RuleDsl

      key :national_insurance_32
      group :none

      client do |_crime_application, applicant|
        NinoEvidenceRequired.for(applicant)
      end

      partner do |_crime_application, partner|
        NinoEvidenceRequired.for(partner)
      end
    end
  end

  class NinoEvidenceRequired
    include TypeOfMeansAssessment

    attr_reader :crime_application, :person

    def initialize(person)
      @person = person
      @crime_application = person.crime_application
    end

    class << self
      def for(person)
        new(person).call
      end
    end

    def call
      return false unless person.over_18_at_date_stamp? && applicant.nino.blank?
      return true if person.income_benefits.any?
      return true if person.applicant? && indictable_or_in_crown_court?

      benefit_check_recipient.is_a?(person.class) && nino_forthcoming?
    end

    private

    def indictable_or_in_crown_court?
      [CaseType::INDICTABLE.to_s, CaseType::ALREADY_IN_CROWN_COURT.to_s]
        .include?(kase&.case_type)
    end
  end
end
