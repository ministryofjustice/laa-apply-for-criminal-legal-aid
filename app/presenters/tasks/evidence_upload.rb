module Tasks
  class EvidenceUpload < BaseTask
    def path
      edit_steps_evidence_upload_path
    end

    def not_applicable?
      Evidence::Requirements.new(crime_application).none?
    end

    def can_start?
      fulfilled?(CaseDetails)
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
