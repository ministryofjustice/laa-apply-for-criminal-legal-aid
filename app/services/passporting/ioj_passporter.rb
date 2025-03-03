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

      age_passported_at_datestamp_or_now?
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

    def ioj_passport_override?
      ioj&.passport_override.present?
    end
  end
end
