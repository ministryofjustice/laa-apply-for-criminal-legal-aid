module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :review
        edit(:declaration)
      when :declaration, :submission_retry
        submit_application
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def submit_application
      if Datastore::ApplicationSubmission.new(current_crime_application).call
        show(:confirmation)
      else
        edit(:failure)
      end
    end
  end
end
