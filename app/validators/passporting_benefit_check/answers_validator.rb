module PassportingBenefitCheck
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :crime_application, to: :record

    def validate
      return if !applicable? || complete?

      errors.add :benefit_type, :incomplete
      errors.add :base, :incomplete_records
    end

    def applicable?
      !(applicant&.under18? || not_means_tested? || crime_application.appeal_no_changes? || arc_present?)
    end

    def complete?
      return false if benefit_check_recipient.benefit_type.blank?
      return true if Passporting::MeansPassporter.new(crime_application).call
      return true if benefit_check_recipient.benefit_type == BenefitType::NONE.to_s
      return true if evidence_of_passporting_means_forthcoming?

      means_assessment_as_benefit_evidence?
    end

    def arc_present?
      return true if applicant&.arc.present? && (partner.nil? || partner.arc.present?)

      false
    end

    alias crime_application record
  end
end
