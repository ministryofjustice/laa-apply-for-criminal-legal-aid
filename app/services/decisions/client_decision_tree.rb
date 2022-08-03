module Decisions
  class ClientDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :has_partner
        after_has_partner
      when :details
        edit(:has_nino)
      when :has_nino
        after_has_nino
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

    def after_has_nino
      if form_object.has_nino.yes?
        edit('/steps/contact/postcode_lookup')
      else
        show('/home', action: :nino_no)
      end
    end
  end
end
