module Tasks
  class MoreInformation < BaseTask
    def path
      edit_steps_submission_more_information_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(EvidenceUpload) || fulfilled?(CaseDetails)
    end

    def in_progress?
      crime_application.additional_information.present?
    end

    def completed?
      in_progress?
    end
  end
end
