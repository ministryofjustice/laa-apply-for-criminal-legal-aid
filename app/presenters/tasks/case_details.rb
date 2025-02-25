module Tasks
  class CaseDetails < BaseTask
    include TypeOfMeansAssessment

    def path
      edit_steps_case_urn_path
    end

    def not_applicable?
      false
    end

    def can_start?
      return fulfilled?(ClientDetails) if partner_information_not_required?

      fulfilled?(PassportingBenefitCheck)
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
