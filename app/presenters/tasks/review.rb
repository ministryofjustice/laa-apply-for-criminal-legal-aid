module Tasks
  class Review < BaseTask
    def path
      edit_steps_submission_review_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(Ioj)
    end

    # Once the Ioj task is fulfilled, this is always true
    def in_progress?
      true
    end

    def completed?
      fulfilled?(Declaration)
    end
  end
end
