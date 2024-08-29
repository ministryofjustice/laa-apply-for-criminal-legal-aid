module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
    include TypeOfMeansAssessment

    alias crime_application current_crime_application

    def destination
      case step_name
      when :more_information
        edit(:review)
      when :review
        after_review
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

    def after_review
      if requires_nino?
        edit(:cannot_submit_without_nino)
      else
        edit(:declaration)
      end
    end

    def after_cannot_submit_without_nino
      if form_object.will_enter_nino.yes?
        edit('steps/shared/nino', subject: 'client')
      else
        edit(:review)
      end
    end

    def requires_nino?
      return false if current_crime_application.not_means_tested?
      return false if current_crime_application.appeal_no_changes?

      nino_forthcoming? && current_crime_application.case.is_client_remanded != 'yes'
    end
  end
end
