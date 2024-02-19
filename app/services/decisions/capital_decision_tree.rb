module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :add_saving
        edit_new_saving
      when :saving
        raise 'Show savings implemented in CRIMAPP-512'
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    def edit_new_saving
      saving_id = if incomplete_savings.present?
                    incomplete_savings.first
                  else
                    savings.create!(saving_type: @form_object.saving_type)
                  end

      edit(:savings, saving_id:)
    end

    def incomplete_savings
      if saving_type
        savings.where(saving_type:).reject(&:complete?)
      else
        savings.reject(&:complete?)
      end
    end

    def saving_type
      @form_object.saving_type
    end

    def savings
      @savings ||= current_crime_application.savings
    end
  end
end
