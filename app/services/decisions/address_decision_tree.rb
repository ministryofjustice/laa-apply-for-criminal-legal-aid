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
        edit('/steps/client/contact_details')
      else
        # TODO: link to next step when we have it
        show('/home', action: :index)
      end
    end
  end
end
