module Decisions
  class SubmissionDecisionTree < BaseDecisionTree
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
        edit('/steps/client/has_nino')
      else
        edit(:review)
      end
    end

    def requires_nino?
      applicant.benefit_type.present? && applicant.has_nino == 'no' &&
        current_crime_application.case.is_client_remanded == 'no'
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
end
