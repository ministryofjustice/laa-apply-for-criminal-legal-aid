module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :review
        edit(:declaration)
      when :declaration
        submit_application
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def submit_application
      ApplicationSubmission.new(current_crime_application).call

      show(:confirmation)
    end
  end
end
