module Decisions
  class DWPDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :retry_benefit_check
        after_retry_benefit_check
      when :confirm_result
        after_confirm_result
      when :confirm_details
        after_confirm_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_retry_benefit_check
      DWP::UpdateBenefitCheckResultService.call(current_crime_application.applicant)

      if current_crime_application.applicant.passporting_benefit.nil?
        edit(:retry_benefit_check)
      elsif current_crime_application.applicant.passporting_benefit?
        edit('steps/client/benefit_check_result')
      else
        edit(:confirm_result)
      end
    end

    def after_confirm_result
      if form_object.confirm_result.yes?
        show(:benefit_check_result_exit)
      else
        edit(:confirm_details)
      end
    end

    def after_confirm_details
      if form_object.confirm_details.yes?
        show(:benefit_check_result_exit)
      else
        edit('steps/client/details')
      end
    end
  end
end
