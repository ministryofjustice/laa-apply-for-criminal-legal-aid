class BenefitCheckService
  def self.call(crime_application)
    # For now we will just use the mock benefit check service
    # and implement the full benefit check service functionality later

    MockBenefitCheckService.call(crime_application)
  end
end
