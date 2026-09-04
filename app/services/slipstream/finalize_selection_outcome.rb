module Slipstream
  class FinalizeSelectionOutcome
    def initialize(crime_application)
      @outcome = crime_application.slipstream_audit_selection_outcome
      @eligibility_checker = EligibilityChecker.new(crime_application)
    end

    def call
      return unless outcome&.selected?

      outcome.with_lock do
        next outcome unless outcome.selected?

        outcome.update!(
          status: eligibility_checker.eligible? ? :confirmed : :withdrawn,
          status_determined_at: Time.current
        )

        outcome
      end
    end

    private

    attr_reader :eligibility_checker, :outcome
  end
end
