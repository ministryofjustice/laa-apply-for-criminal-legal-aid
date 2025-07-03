module Decisions
  # rubocop:disable Metrics/ClassLength
  class DWPDecisionTree < BaseDecisionTree
    include TypeOfMeansAssessment

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :benefit_type
        after_benefit_type
      when :partner_benefit_type
        after_partner_benefit_type
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
      when :partner_confirm_result
        after_partner_confirm_result
      when :confirm_details
        after_confirm_details
      when :cannot_match_details
        after_cannot_match_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_confirm_result
      throw 'here'
      if form_object.confirm_dwp_result.yes?
        return edit(:partner_benefit_type) if include_partner_in_means_assessment?

        edit('steps/case/urn')
      else
        edit(:confirm_details)
      end
    end

    def after_partner_confirm_result
      if form_object.confirm_dwp_result.yes?
        edit('steps/case/urn')
      else
        edit(:confirm_details)
      end
    end

    def after_confirm_details
      if form_object.confirm_details.yes?
        edit(:has_benefit_evidence)
      else
        determine_client_details_routing
      end
    end

    def after_benefit_type
      return edit(:partner_benefit_type) if partner_benefit_type_required?

      benefit_check_routing(applicant)
    end

    def after_partner_benefit_type
      benefit_check_routing(partner)
    end

    def benefit_check_routing(person)
      if form_object.benefit_type.none?
        edit('/steps/case/urn')
      elsif !has_nino(person)
        edit(:cannot_check_benefit_status)
      else
        determine_dwp_result_page(person)
      end
    end

    def partner_benefit_type_required?
      return false if partner&.arc.present?

      form_object.benefit_type.none? && include_partner_in_means_assessment?
    end

    def after_has_benefit_evidence
      edit('/steps/case/urn')
    end

    def after_cannot_check_benefit_status
      if form_object.will_enter_nino.yes?
        determine_nino_routing
      else
        edit('/steps/case/urn')
      end
    end

    def determine_nino_routing
      subject = partner_is_recipient? ? 'partner' : 'client'

      edit('steps/shared/nino', subject:)
    end

    def determine_client_details_routing
      return edit('steps/partner/details') if partner_is_recipient?

      edit('steps/client/details')
    end

    def determine_dwp_result_page(person)
      return edit(:benefit_check_result) if current_crime_application.benefit_check_passported?

      DWP::UpdateBenefitCheckResultService.call(person)

      if person.dwp_response.nil?
        edit(:cannot_check_dwp_status)
      elsif person.dwp_response == 'Yes'
        edit(:benefit_check_result)
      elsif person.dwp_response == 'Undetermined'
        edit(:cannot_match_details)
      else
        return edit(:partner_confirm_result) if person.type == 'Partner'

        edit(:confirm_result)
      end
    end

    def after_cannot_check_dwp_status
      person = benefit_check_subject

      determine_dwp_result_page(person)
    end

    def after_cannot_match_details
      edit(:confirm_details)
    end

    def has_nino(person)
      person.has_nino == 'yes'
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end

    def partner
      @partner ||= current_crime_application.partner
    end

    def crime_application
      current_crime_application
    end

    def partner_is_recipient?
      partner&.has_passporting_benefit?
    end
  end
  # rubocop:enable Metrics/ClassLength
end
