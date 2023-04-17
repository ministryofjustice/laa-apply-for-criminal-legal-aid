module Passporting
  class MeansPassporter < BasePassporter
    def call
      means_passport = []
      means_passport << MeansPassportType::ON_AGE_UNDER18   if applicant_under18?
      means_passport << MeansPassportType::ON_BENEFIT_CHECK if benefit_check_passed?

      crime_application.update(means_passport:)

      passported?
    end

    def passported?
      crime_application.means_passport.any?
    end

    private

    def benefit_check_passed?
      applicant.passporting_benefit.present?
    end
  end
end
