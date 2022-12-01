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
      # Get it before we purge the local DB record
      reference = current_crime_application.usn

      if ApplicationSubmission.new(current_crime_application).call
        show(:confirmation, reference:)
      else
        # TODO: we need a more user-friendly unhappy path
        # for when the submission or datastore fail
        show('/errors', action: :unhandled, id: nil)
      end
    end
  end
end
