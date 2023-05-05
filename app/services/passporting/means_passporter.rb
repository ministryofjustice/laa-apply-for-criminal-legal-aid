module Passporting
  class MeansPassporter < BasePassporter
    def call
      return passported? if resubmission?

      means_passport = []
      means_passport << MeansPassportType::ON_AGE_UNDER18   if applicant_under18?
      means_passport << MeansPassportType::ON_BENEFIT_CHECK if benefit_check_passed?

      crime_application.update(means_passport:)

      passported?
    end

    def passported?
      age_passported? || benefit_check_passported?
    end

    def age_passported?
      return passported_on?(MeansPassportType::ON_AGE_UNDER18) if resubmission?

      applicant_under18?
    end

    def benefit_check_passported?
      return passported_on?(MeansPassportType::ON_BENEFIT_CHECK) if resubmission?

      benefit_check_passed?
    end

    def passport_types_collection
      crime_application.means_passport
    end

    private

    def applicant_under18?
      FeatureFlags.u18_means_passport.enabled? && super
    end

    def benefit_check_passed?
      applicant.passporting_benefit.present?
    end
  end
end
