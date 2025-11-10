module DWP
  class UpdateBenefitCheckResultService
    def initialize(person)
      @person = person
    end

    def self.call(*)
      new(*).call
    end

    def call
      if FeatureFlags.dwp_undetermined.enabled?
        dwp_response = BenefitCheckService.benefit_check_result(@person)
        benefit_check_result = dwp_response.casecmp('yes').zero?
        @person.update(dwp_response:, benefit_check_result:)
      else
        benefit_check_result = BenefitCheckService.passporting_benefit?(@person)
        @person.update(benefit_check_result:)
      end
    end
  end
end
