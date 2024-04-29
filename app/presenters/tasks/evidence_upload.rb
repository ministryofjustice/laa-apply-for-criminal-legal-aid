module Tasks
  class EvidenceUpload < BaseTask
    def path
      edit_steps_evidence_upload_path
    end

    def not_applicable?
      false
    end

    def can_start?
      true
    end

    def in_progress?
      documents.any?
    end

    def completed?
      documents.stored.any?
    end

    private

    def documents
      @documents ||= crime_application.documents
    end
  end
end
