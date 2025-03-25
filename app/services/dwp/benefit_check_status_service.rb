module DWP
  class BenefitCheckStatusService
    include TypeOfMeansAssessment

    def initialize(crime_application, person)
      @crime_application = crime_application
      @person = person
    end

    def self.call(*)
      new(*).call
    end

    def call
      return BenefitCheckStatus::NO_CHECK_REQUIRED.to_s unless person_is_recipient?

      benefit_check_status
    end

    private

    attr_reader :crime_application, :person

    def benefit_check_status
      return BenefitCheckStatus::NO_CHECK_NO_NINO.to_s if nino_forthcoming?
      return undetermined_status if dwp_undetermined
      return BenefitCheckStatus::NO_CHECK_REQUIRED.to_s if benefit_check_subject.benefit_type == 'none'
      return BenefitCheckStatus::CHECKER_UNAVAILABLE.to_s if checker_down

      BenefitCheckStatus::CONFIRMED.to_s if benefit_check_subject.benefit_check_result
    end

    def undetermined_status
      return BenefitCheckStatus::UNDETERMINED.to_s if benefit_evidence_forthcoming?

      BenefitCheckStatus::NO_RECORD_FOUND.to_s if means_assessment_as_benefit_evidence?
    end

    def dwp_undetermined
      benefit_check_subject.confirm_dwp_result == 'no'
    end

    def checker_down
      benefit_check_subject.benefit_check_result.nil? && benefit_check_subject.has_benefit_evidence.present?
    end

    def person_is_recipient?
      benefit_check_subject.id == person.id
    end
  end
end
