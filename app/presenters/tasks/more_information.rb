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
      crime_application.additional_information_required.present?
    end

    def completed?
      return false if crime_application.additional_information_required.blank?
      return true if crime_application.additional_information_required == 'no'

      crime_application.additional_information.present?
    end
  end
end
