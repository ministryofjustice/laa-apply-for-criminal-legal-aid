module Decisions
  class AddressDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lookup
        edit(:results)
      when :results, :details
        after_address_entered
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_address_entered
      if form_object.record.is_a?(HomeAddress)
        if form_object.record.person.is_a?(Partner)
          edit('/steps/client/has_nino') # TODO: Check if correct entry point
        else
          edit('/steps/client/contact_details')
        end
      elsif current_crime_application.age_passported?
        edit('/steps/case/urn')
      else
        edit('/steps/client/has_nino')
      end
    end
  end
end
