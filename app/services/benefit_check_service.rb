class BenefitCheckService
  def self.call(applicant)
    # For now we will just use the mock benefit check service
    # and implement the full benefit check service functionality later

    MockBenefitCheckService.call(applicant)
  end
end
