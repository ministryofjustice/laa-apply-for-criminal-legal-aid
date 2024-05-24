module DWP
  class BenefitCheckStatusService
    include TypeOfMeansAssessment

    def initialize(crime_application, applicant)
      @crime_application = crime_application
      @applicant = applicant
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      benefit_check_status
    end

    private

    attr_reader :crime_application, :applicant

    def benefit_check_status
      return BenefitCheckStatus::NO_CHECK_NO_NINO.to_s if nino_forthcoming?
      return BenefitCheckStatus::UNDETERMINED.to_s if benefit_evidence_forthcoming?
      return BenefitCheckStatus::NO_RECORD_FOUND.to_s if means_assessment_as_benefit_evidence?
      return BenefitCheckStatus::NO_CHECK_REQUIRED.to_s if applicant.benefit_type == 'none'
      return BenefitCheckStatus::CHECKER_UNAVAILABLE.to_s if checker_down

      BenefitCheckStatus::CONFIRMED.to_s if applicant.benefit_check_result
    end

    def checker_down
      applicant.benefit_check_result.nil? && applicant.has_benefit_evidence.present?
    end
  end
end
