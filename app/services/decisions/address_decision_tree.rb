module Decisions
  class AddressDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lookup
        edit(:results)
      when :results, :details, :clear_address
        after_address_entered
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_address_entered
      if form_object.record.is_a?(HomeAddress)
        edit('/steps/client/contact_details')
      elsif form_object.record.is_a?(PartnerAddress)
        edit('/steps/partner/address_details')
      elsif current_crime_application.age_passported?
        edit('/steps/case/urn')
      else
        edit('/steps/client/has_nino')
      end
    end
  end
end
