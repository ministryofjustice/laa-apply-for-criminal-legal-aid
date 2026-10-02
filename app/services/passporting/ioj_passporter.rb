module Passporting
  class IojPassporter < BasePassporter
    def call
      ioj_passport = passport_types_for_current_details

      crime_application.update(ioj_passport:)

      passported?
    end

    def passported?
      # IoJ passporting can be overridden for applications returned
      # back to the provider due to the case being split
      if crime_application.slipstream_audit_selection_outcome.present?
        normal_passported = passported_without_audit?
        return normal_passported && !audit_ioj_required?(normal_passported)
      end

      passport_types_collection.any? && !ioj_passport_override?
    end

    def passported_without_audit?
      passport_types_for_current_details.any? && !ioj_passport_override?
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

    def passport_types_for_current_details
      @passport_types_for_current_details ||= begin
        types = []
        types << IojPassportType::ON_AGE_UNDER18 if age_passported?
        types << IojPassportType::ON_OFFENCE if offence_passported?
        types
      end
    end

    def audit_ioj_required?(normally_passported)
      requirement = Slipstream::AuditIojRequirement.new(crime_application)
      requirement.required?(normally_passported:)
    end
  end
end
