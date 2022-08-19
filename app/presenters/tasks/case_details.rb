module Tasks
  class CaseDetails < BaseTask
    # TODO: update when we have the case details steps
    def path
      ''
    end

    def not_applicable?
      false
    end

    # Case details can start once the DWP check passes
    # TODO: update when we have the real check
    def can_start?
      crime_application.applicant&.nino.present?
    end

    # TODO: update when we have the case details steps
    def in_progress?
      false
    end

    # TODO: update when we have the case details steps
    def completed?
      false
    end
  end
end
