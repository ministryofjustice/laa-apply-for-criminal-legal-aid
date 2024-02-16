module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :add_saving
        edit_new_saving
      when :saving
        raise "Show savings implemented in CRIMAPP-512"
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    def edit_new_saving
      saving = incomplete_savings.present? ? incomplete_savings.first : savings.create!(saving_type: @form_object.saving_type)

      edit(:savings, saving_id: saving)
    end

    def incomplete_saving_for_type
      savings.where(saving_type:).reject(&:complete?)
    end

    def saving_type
      @form_object.saving_type
    end

    def savings
      @savings ||= current_crime_application.savings
    end
  end
end
