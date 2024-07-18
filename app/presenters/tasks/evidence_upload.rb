module Tasks
  class EvidenceUpload < BaseTask
    def path
      edit_steps_evidence_upload_path
    end

    def can_start?
      crime_application.applicant.present?
    end

    def in_progress?
      crime_application.documents.any?
    end

    def not_applicable?
      false
    end

    def completed?
      false
    end
  end
end
