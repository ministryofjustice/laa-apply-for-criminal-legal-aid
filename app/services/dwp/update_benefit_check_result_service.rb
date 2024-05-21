module DWP
  class UpdateBenefitCheckResultService
    def initialize(applicant)
      @applicant = applicant
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      benefit_check_result = BenefitCheckService.passporting_benefit?(@applicant)

      @applicant.update(benefit_check_result:)
    end
  end
end
