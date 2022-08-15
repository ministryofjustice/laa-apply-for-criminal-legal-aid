module Decisions
  class ClientDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        edit(:has_nino)
      when :has_nino
        after_has_nino
      when :contact_details
        after_contact_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_has_partner
      if form_object.client_has_partner.yes?
        show(:partner_exit)
      else
        edit(:details)
      end
    end

    def after_has_nino
      start_address_journey(
        HomeAddress,
        form_object.applicant
      )
    end

    def after_contact_details
      if CorrespondenceType.new(form_object.correspondence_address_type).other_address?
        start_address_journey(
          CorrespondenceAddress,
          form_object.applicant
        )
      else
        show('/home', action: :index)
      end
    end

    def start_address_journey(address_class, person)
      address = address_class.find_or_create_by(person: person)
      edit('/steps/address/lookup', id: address)
    end
  end
end
