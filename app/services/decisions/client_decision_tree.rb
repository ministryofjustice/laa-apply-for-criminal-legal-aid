module Decisions
  class ClientDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_has_partner
      if form_object.client_has_partner.yes?
        show('/home', action: :selected_yes)
      else
        edit(:details)
      end
    end
  end
end
