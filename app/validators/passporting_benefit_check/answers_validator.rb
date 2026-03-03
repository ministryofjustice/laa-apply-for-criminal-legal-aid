module PassportingBenefitCheck
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, to: :record

    def validate
      return if !applicable? || complete?

      errors.add :benefit_type, :incomplete
      errors.add :base, :incomplete_records
    end

    def applicable?
      !(age_passported? || not_means_tested? || appeal_no_changes? || not_applicable_on_arc?)
    end

    def complete?
      return true if Passporting::MeansPassporter.new(crime_application).call
      return true if benefit_check_subject.arc.present?
      return true if benefit_check_subject.benefit_type == BenefitType::NONE.to_s
      return true if evidence_of_passporting_means_forthcoming?

      means_assessment_as_benefit_evidence?
    end

    def not_applicable_on_arc?
      return true if applicant&.arc.present? && (partner.nil? || partner.arc.present?)

      false
    end

    alias crime_application record
  end
end
