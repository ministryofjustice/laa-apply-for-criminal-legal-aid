module Decisions
  class DWPDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :benefit_type
        after_benefit_type
      when :benefit_check_result
        edit('/steps/case/urn')
      when :has_benefit_evidence
        after_has_benefit_evidence
      when :cannot_check_benefit_status
        after_cannot_check_benefit_status
      when :cannot_check_dwp_status
        after_cannot_check_dwp_status
      when :confirm_result
        after_confirm_result
      when :confirm_details
        after_confirm_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_confirm_result
      if form_object.confirm_dwp_result.yes? # Do we want to reset their ppt benefit to None if they select Yes here?
        if FeatureFlags.means_journey.enabled?
          edit('steps/case/urn')
        else
          show(:benefit_check_result_exit)
        end
      else
        edit(:confirm_details)
      end
    end

    def after_confirm_details
      if form_object.confirm_details.yes?
        edit(:has_benefit_evidence)
      else
        edit('steps/client/details')
      end
    end

    def after_benefit_type
      if form_object.benefit_type.none?
        if FeatureFlags.means_journey.enabled?
          edit('/steps/case/urn')
        else
          show(:benefit_exit)
        end
      elsif !applicant_has_nino
        edit(:cannot_check_benefit_status)
      else
        determine_dwp_result_page
      end
    end

    def after_has_benefit_evidence
      if form_object.has_benefit_evidence.yes? || FeatureFlags.means_journey.enabled?
        edit('/steps/case/urn')
      else
        show(:evidence_exit)
      end
    end

    def after_cannot_check_benefit_status
      if form_object.will_enter_nino.yes?
        edit('steps/client/has_nino')
      else
        edit('/steps/case/urn')
      end
    end

    def determine_dwp_result_page
      return edit(:benefit_check_result) if current_crime_application.benefit_check_passported?

      DWP::UpdateBenefitCheckResultService.call(applicant)

      if applicant.passporting_benefit.nil?
        edit(:cannot_check_dwp_status)
      elsif applicant.passporting_benefit
        edit(:benefit_check_result)
      else
        edit(:confirm_result)
      end
    end

    def after_cannot_check_dwp_status
      determine_dwp_result_page
    end

    def applicant_has_nino
      return true unless FeatureFlags.means_journey.enabled?

      applicant.has_nino == 'yes'
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
end
