class UpdateBenefitCheckResultService
  def initialize(applicant)
    @applicant = applicant
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    passporting_benefit = BenefitCheckService.call(@applicant)[:benefit_checker_status].casecmp('yes').zero?

    @applicant.update(passporting_benefit:)
  end
end
