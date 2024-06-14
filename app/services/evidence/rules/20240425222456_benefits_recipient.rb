module Evidence
  module Rules
    class BenefitsRecipient < Rule
      include Evidence::RuleDsl

      key :income_benefits_0b
      group :income

      client do |_crime_application, applicant|
        applicant.present? && BenefitEvidenceRequired.for(applicant)
      end

      partner do |_crime_application, partner|
        partner.present? && BenefitEvidenceRequired.for(partner)
      end
    end
  end

  class BenefitEvidenceRequired
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
      return false if Passporting::MeansPassporter.new(crime_application).call

      benefit_check_recipient.is_a?(person.class) && benefit_evidence_forthcoming?
    end
  end
end
