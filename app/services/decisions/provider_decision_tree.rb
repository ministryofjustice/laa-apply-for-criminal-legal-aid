module Decisions
  class ProviderDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :confirm_office
        after_confirm_office
      when :select_office
        dashboard_url
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_confirm_office
      if form_object.is_current_office.yes?
        dashboard_url
      else
        edit(:select_office)
      end
    end

    def dashboard_url
      show('/crime_applications', action: :index)
    end
  end
end
