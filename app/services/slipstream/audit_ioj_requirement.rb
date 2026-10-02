module Slipstream
  class AuditIojRequirement
    def initialize(crime_application)
      @crime_application = crime_application
    end

    def required?(normally_passported:)
      return false unless FeatureFlags.slipstream_audit.enabled?
      return false unless active_outcome? && eligible_for_recorded_reason?

      normally_passported
    end

    private

    attr_reader :crime_application

    def outcome
      crime_application.slipstream_audit_selection_outcome
    end

    def active_outcome?
      outcome&.selected? || outcome&.confirmed?
    end

    def eligible_for_recorded_reason?
      checker = EligibilityChecker.new(crime_application)

      case outcome.selection_reason
      when 'age'
        # Age-based selections remain in the sample if the applicant ages out.
        true
      when 'offence'
        checker.single_slipstreamable_offence?
      else
        checker.eligible?
      end
    end
  end
end
