module Decisions
  class ClientDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        after_client_details
      when :has_nino, :retry_benefit_check
        after_has_nino
      when :benefit_check_result
        after_dwp_check
      when :contact_details
        after_contact_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength

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
      if AgeCalculator.new(current_crime_application.applicant).under18?
        start_address_journey(HomeAddress)
      else
        edit(:has_nino)
      end
    end

    def after_has_nino
      DWP::UpdateBenefitCheckResultService.call(current_crime_application.applicant)

      if current_crime_application.applicant.passporting_benefit.nil?
        edit(:retry_benefit_check)
      elsif current_crime_application.applicant.passporting_benefit?
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
        edit('/steps/case/urn')
      end
    end

    def start_address_journey(address_class)
      person = current_crime_application.applicant
      address = address_class.find_or_create_by(person:)

      edit('/steps/address/lookup', address_id: address)
    end
  end
end
