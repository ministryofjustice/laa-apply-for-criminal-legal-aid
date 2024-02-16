module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :add_saving
        edit_new_saving
      when :saving
        # TODO: add next step
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    def edit_new_saving
      saving = incomplete_savings.present? ? incomplete_savings.first : savings.create!(saving_type: @form_object.saving_type)

      edit(:savings, saving_id: saving)
    end

    def incomplete_savings
      savings.reject(&:complete?)
    end

    def savings
      @savings ||= current_crime_application.savings
    end
  end
end
