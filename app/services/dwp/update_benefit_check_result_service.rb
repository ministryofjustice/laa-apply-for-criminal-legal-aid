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

      @person.update(dwp_response:)
    end
  end
end
