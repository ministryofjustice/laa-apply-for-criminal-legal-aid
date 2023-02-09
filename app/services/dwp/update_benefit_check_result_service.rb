module DWP
  class UpdateBenefitCheckResultService
    def initialize(applicant)
      @applicant = applicant
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      passporting_benefit = BenefitCheckService.passporting_benefit?(@applicant)

      @applicant.update(passporting_benefit:)
    end
  end
end
