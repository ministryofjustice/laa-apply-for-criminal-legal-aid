module Tasks
  class Declaration < BaseTask
    def path
      edit_steps_submission_declaration_path
    end

    def not_applicable?
      false
    end

    def can_start?
      if crime_application.pse?
        fulfilled?(EvidenceUpload)
      else
        fulfilled?(CaseDetails) && crime_application.valid?(:submission)
      end
    end

    def in_progress?
      !!crime_application.legal_rep_first_name
    end

    # `in_progress` applications will never have this task
    # marked as completed, as the completion means submitting it
    def completed?
      false
    end
  end
end
