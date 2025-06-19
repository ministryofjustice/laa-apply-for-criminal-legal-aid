module DWP
  class UpdateBenefitCheckResultService
    def initialize(applicant)
      @applicant = applicant
    end

    def self.call(*)
      new(*).call
    end

    def call
      dwp_response = BenefitCheckService.passporting_benefit?(@applicant)

      @applicant.update(dwp_response:)
    end
  end
end
