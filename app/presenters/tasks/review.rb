module Tasks
  class Review < BaseTask
    def path
      edit_steps_submission_review_path
    end

    def not_applicable?
      false
    end

    def can_start?
      if crime_application.pse?
        fulfilled?(EvidenceUpload)
      else
        fulfilled?(Ioj)
      end
    end

    # Once the Ioj task is fulfilled, this is always true
    def in_progress?
      true
    end

    def completed?
      crime_application.values_at(
        :legal_rep_first_name, :legal_rep_last_name, :legal_rep_telephone
      ).any?
    end
  end
end
