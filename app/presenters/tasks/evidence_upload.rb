module Tasks
  class EvidenceUpload < BaseTask
    def path
      edit_steps_evidence_upload_path
    end

    def can_start?
      true
    end

    def in_progress?
      true
    end

    private

    def validator
      @validator ||= ::SupportingEvidence::AnswersValidator.new(
        record: crime_application, crime_application: crime_application
      )
    end
  end
end
