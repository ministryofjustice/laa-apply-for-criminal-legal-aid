module Tasks
  class AdditionalInformation < BaseTask
    def path
      edit_steps_evidence_additional_information_path
    end

    def not_applicable?
      !crime_application.pse?
    end

    def can_start?
      fulfilled?(EvidenceUpload)
    end

    def in_progress?
      crime_application.additional_information.present?
    end

    def completed?
      in_progress?
    end
  end
end
