module PassportingBenefit
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :crime_application, to: :record

    # Adds the error to the first step name a user would need to go to fix the issue.

    def validate
      errors.add(:benefit_type, :blank) unless benefit_type_complete?

      benefit_questions_complete? if has_passporting_benefit?

      errors.add :base, :incomplete_records unless errors.empty?
    end

    def benefit_type_complete?
      applicant.benefit_type.present?
    end

    def benefit_questions_complete?
      # passed the dwp check
      return true if applicant.passporting_benefit == 'true'

      errors.add(:will_enter_nino, :blank) unless will_enter_nino_complete?

      unless dwp_check_not_undertaken?
        errors.add(:confirm_dwp_result, :blank) unless confirm_dwp_result_complete?
        errors.add(:has_benefit_evidence, :blank) unless has_benefit_evidence_complete?
      end
    end

    def will_enter_nino_complete?
      applicant.has_nino == 'no' ? applicant.will_enter_nino.present? : true
    end

    def confirm_dwp_result_complete?
      # bypassed as they didn't undertake dwp check
      return true if applicant.has_nino == 'no'

      record.confirm_dwp_result.present?
    end

    def has_benefit_evidence_complete?
      return true unless record.confirm_dwp_result == 'no'

      applicant.has_benefit_evidence.present?
    end

    def dwp_check_not_undertaken?
      # could be because the checker is down or applicant has no pp benefit or nino
      applicant.passporting_benefit.nil?
    end

    alias crime_application record
  end
end
