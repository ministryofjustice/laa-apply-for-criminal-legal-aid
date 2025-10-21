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
      return BenefitCheckStatus::NO_CHECK_REQUIRED.to_s if benefit_check_subject.benefit_type == 'none'
      return BenefitCheckStatus::NO_CHECK_NO_NINO.to_s if nino_forthcoming?
      return BenefitCheckStatus::CHECKER_UNAVAILABLE.to_s if checker_down
      return BenefitCheckStatus::UNDETERMINED.to_s if undetermined
      return BenefitCheckStatus::NO_RECORD_FOUND.to_s if not_in_receipt

      BenefitCheckStatus::CONFIRMED.to_s if confirmed
    end

    def undetermined
      benefit_check_subject.dwp_response == 'Undetermined' ||
        (benefit_check_subject.confirm_dwp_result == 'no' && benefit_evidence_forthcoming?)
    end

    def not_in_receipt
      benefit_check_subject.dwp_response == 'No' ||
        (benefit_check_subject.confirm_dwp_result == 'no' && means_assessment_as_benefit_evidence?)
    end

    def confirmed
      benefit_check_subject.benefit_check_result
    end

    def checker_down
      benefit_check_subject.benefit_check_result.nil? && benefit_check_subject.has_benefit_evidence.present?
    end

    def person_is_recipient?
      benefit_check_subject.id == person.id
    end
  end
end
