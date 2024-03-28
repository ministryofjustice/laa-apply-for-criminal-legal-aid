module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :more_information
        edit(:review)
      when :review
        edit(:declaration)
      when :declaration, :submission_retry
        submit_application
      when :cannot_submit_without_nino
        after_cannot_submit_without_nino
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

    def after_cannot_submit_without_nino
      if form_object.will_enter_nino.yes?
        edit(:has_nino)
      else
        edit('/steps/case/urn')
      end
    end
  end
end
