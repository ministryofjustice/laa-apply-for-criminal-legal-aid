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
        edit(:benefit_check_result)
      when :benefit_check_result
        after_benefit_check_result
      when :confirm_nino_details
        after_confirm_nino_details
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
        show('/crime_applications', action: :edit)
      end
    end

    def after_benefit_check_result
      return edit(:confirm_nino_details) if form_object.applicant.passporting_benefit.nil?

      if form_object.applicant.passporting_benefit.casecmp('yes').zero?
        start_address_journey(
          HomeAddress,
          form_object.applicant
        )
      else
        show(:benefit_check_result_exit)
      end
    end

    def after_confirm_nino_details
      if form_object.confirm_nino_details.casecmp('yes').zero?
        show(:benefit_check_result_exit)
      else
        edit(:details)
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
