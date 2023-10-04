module Decisions
  class ClientDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        after_client_details
      when :has_nino
        edit(:benefit_type)
      when :benefit_type
        after_benefit_type
      when :retry_benefit_check
        determine_dwp_result_page
      when :benefit_check_result
        after_dwp_check
      when :contact_details
        after_contact_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_has_partner
      if form_object.client_has_partner.yes?
        show(:partner_exit)
      else
        # Task list
        edit('/crime_applications')
      end
    end

    def after_client_details
      if current_crime_application.age_passported?
        start_address_journey(HomeAddress)
      else
        edit(:has_nino)
      end
    end

    def after_benefit_type
      if form_object.benefit_type.none?
        show(:benefit_exit)
      else
        determine_dwp_result_page
      end
    end

    def determine_dwp_result_page
      return edit(:benefit_check_result) if current_crime_application.benefit_check_passported?

      DWP::UpdateBenefitCheckResultService.call(applicant)

      if applicant.passporting_benefit.nil?
        edit(:retry_benefit_check)
      elsif applicant.passporting_benefit
        edit(:benefit_check_result)
      else
        edit('steps/dwp/confirm_result')
      end
    end

    def after_dwp_check
      start_address_journey(HomeAddress)
    end

    def after_contact_details
      if form_object.correspondence_address_type.other_address?
        start_address_journey(CorrespondenceAddress)
      else
        edit('/steps/case/case_type')
      end
    end

    def start_address_journey(address_class)
      address = address_class.find_or_create_by(person: applicant)

      edit('/steps/address/lookup', address_id: address)
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
end
