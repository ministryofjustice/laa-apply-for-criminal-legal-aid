module Passporting
  class IojPassporter < BasePassporter
    def call
      ioj_passport = []
      ioj_passport << IojPassportType::ON_AGE_UNDER18 if age_passported?

      crime_application.update(ioj_passport:)

      passported?
    end

    def passported?
      # IoJ passporting can be overridden for applications returned
      # back to the provider due to the case being split
      passport_types_collection.any? && !ioj_passport_override?
    end

    def age_passported?
      # For resubmissions, we use the original age passport result,
      # instead of running a new age calculation
      return passported_on?(IojPassportType::ON_AGE_UNDER18) if resubmission?

      applicant_under18?
    end

    def passport_types_collection
      crime_application.ioj_passport
    end

    private

    def applicant_under18?
      FeatureFlags.u18_ioj_passport.enabled? && super
    end

    def ioj_passport_override?
      ioj&.passport_override.present?
    end
  end
end
