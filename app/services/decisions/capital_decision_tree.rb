module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength
      case step_name
      when :property_type
        after_property_type(form_object.property)
      when :properties
        # TODO: Route to approprite property page loop once built
        edit(:saving_type) # Placeholder to join up flow
      when :saving_type
        after_saving_type(form_object.saving)
      when :savings
        # TODO: Route to approprite savings page loop once built
        edit(:premium_bonds) # Placeholder to join up flow
      when :premium_bonds
        # TODO: Route to national savings certificates once built
        edit('/steps/case/urn') # Placeholder to join up flow
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_saving_type(saving)
      return edit(:premium_bonds) unless saving

      edit(:savings, saving_id: saving)
    end

    def after_property_type(property)
      return edit(:saving_type) unless property

      edit(:properties, property_id: property)
    end
  end
end
