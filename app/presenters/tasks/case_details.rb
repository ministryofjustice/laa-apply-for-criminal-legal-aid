module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_urn_path
    end

    def not_applicable?
      false
    end

    def can_start?
      return fulfilled?(ClientDetails) if appeal_no_changes? || applicant&.under18?

      fulfilled?(PassportingBenefit)
    end

    delegate :kase, :appeal_no_changes?, to: :crime_application

    # If we have a `case` record we consider this in progress
    def in_progress?
      kase.present?
    end

    def completed?
      kase.complete?
    end
  end
end
