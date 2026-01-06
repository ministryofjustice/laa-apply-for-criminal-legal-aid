module DWP
  class UpdateBenefitCheckResultService
    def initialize(person)
      @person = person
    end

    def self.call(*)
      new(*).call
    end

    def call
      dwp_response = BenefitCheckService.benefit_check_result(@person)
      benefit_check_result = dwp_response&.casecmp('yes')&.zero?
      @person.update(dwp_response:, benefit_check_result:)
    end
  end
end
