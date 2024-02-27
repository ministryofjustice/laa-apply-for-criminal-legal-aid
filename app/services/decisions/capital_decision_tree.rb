module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :saving_type
        after_saving_type(form_object.saving)
      when :savings
        # TODO: Add next step
      when :property_type
        after_property_type(form_object.property)
      when :properties
        # TODO: Update next step
        edit(:saving_type)
      when :premium_bonds
        # TODO: Add next step
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
