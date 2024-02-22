module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :saving_type
        after_saving_type(form_object.saving)
      when :savings
        # TODO: Add next step
      when :property_type
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
  end
end
