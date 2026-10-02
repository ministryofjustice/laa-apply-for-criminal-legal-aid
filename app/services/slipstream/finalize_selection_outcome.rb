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
          status: eligible_at_submission? ? :confirmed : :withdrawn,
          status_determined_at: Time.current
        )

        outcome
      end
    end

    private

    def eligible_at_submission?
      # Age-based selections remain in the sample if the applicant ages out
      # before submission. The persisted reason records the category at selection.
      outcome.age? || eligibility_checker.eligible?
    end

    attr_reader :eligibility_checker, :outcome
  end
end
