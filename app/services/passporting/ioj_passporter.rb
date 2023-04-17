module Passporting
  class IojPassporter < BasePassporter
    def call
      ioj_passport = []
      ioj_passport << IojPassportType::ON_AGE_UNDER18 if applicant_under18?

      crime_application.update(ioj_passport:)

      passported?
    end

    def passported?
      # IoJ passporting can be overridden for applications returned
      # back to the provider due to the case being split
      crime_application.ioj_passport.any? && !ioj_passport_override?
    end

    private

    def applicant_under18?
      FeatureFlags.u18_ioj_passport.enabled? && super
    end

    def ioj_passport_override?
      !!ioj.try(:passport_override)
    end
  end
end
