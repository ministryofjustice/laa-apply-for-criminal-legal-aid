module Passporting
  class IojPassporter < BasePassporter
    def call
      ioj_passport = []
      ioj_passport << IojPassportType::ON_AGE_UNDER18 if age_passported?
      ioj_passport << IojPassportType::ON_OFFENCE     if offence_passported?

      crime_application.update(ioj_passport:)

      passported?
    end

    def passported?
      # IoJ passporting can be overridden for applications returned
      # back to the provider due to the case being split
      passport_types_collection.any? && !ioj_passport_override?
    end

    def age_passported?
      # Appeal cases do not trigger IoJ passporting
      return false if appeal_case_type?

      # For resubmissions, we use the original age passport result,
      # instead of running a new age calculation
      return passported_on?(IojPassportType::ON_AGE_UNDER18) if resubmission?

      applicant_under18?
    end

    def offence_passported?
      # Appeal cases do not trigger IoJ passporting
      return false if appeal_case_type?

     offences.any?(&:slipstreamable)
    end

    def passport_types_collection
      crime_application.ioj_passport
    end

    private

    def kase
      @kase ||= crime_application.case
    end

    def offences
      kase.charges.filter_map(&:offence)
    end

    def appeal_case_type?
      return false if kase.case_type.nil?

      CaseType.new(kase.case_type).appeal?
    end

    def applicant_under18?
      FeatureFlags.u18_ioj_passport.enabled? && super
    end

    def ioj_passport_override?
      ioj&.passport_override.present?
    end
  end
end
