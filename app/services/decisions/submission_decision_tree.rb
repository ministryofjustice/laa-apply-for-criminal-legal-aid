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
      if @crime_application.application_type == ApplicationType::POST_SUBMISSION_EVIDENCE.to_s
        if Datastore::PostSubmissionEvidence.new(current_crime_application).call
          show(:confirmation)
        else
          edit(:failure)
        end
      else
        if Datastore::ApplicationSubmission.new(current_crime_application).call
          show(:confirmation)
        else
          edit(:failure)
        end
      end
    end
  end
end
