module Decisions
  # TODO: Break to new `initial_details` tree
  class PartnerDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :details
        edit(:involvement)
      when :involvement
        if partner.has_contrary_interests?
          edit('/steps/client/has_nino')
        else
          edit(:address)
        end
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def partner
      @partner ||= current_crime_application.partner
    end
  end
end
