module Decisions
  class ClientDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        edit(:has_nino)
      when :has_nino
        after_has_nino
      when :benefit_check_result
        start_address_journey(
          HomeAddress,
          form_object.applicant
        )
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

    def after_has_nino
      UpdateBenefitCheckResultService.call(form_object.applicant)

      if form_object.applicant.passporting_benefit?
        edit(:benefit_check_result)
      else
        edit('steps/dwp/confirm_result')
      end
    end

    def after_contact_details
      if form_object.correspondence_address_type.other_address?
        start_address_journey(
          CorrespondenceAddress,
          form_object.applicant
        )
      else
        edit('/steps/case/urn')
      end
    end

    def start_address_journey(address_class, person)
      address = address_class.find_or_create_by(person:)
      edit('/steps/address/lookup', address_id: address)
    end
  end
end
