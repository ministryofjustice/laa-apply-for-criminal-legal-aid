module Decisions
  # TODO: Break to new `initial_details` tree
  class PartnerDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :details
        edit(:involvement)
      when :involvement
        if partner.has_contrary_interests?
          after_partner_journey
        else
          edit(:home_address)
        end
      when :home_address
        if partner.same_home_address_as_client? 
          after_partner_journey
        else
          start_address_journey(HomeAddress) 
        end
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_partner_journey
      edit('/steps/client/has_nino')
    end

    def start_address_journey(address_class)
      address = address_class.find_or_create_by(person: partner)

      edit('/steps/address/lookup', address_id: address)
    end
  end
end
