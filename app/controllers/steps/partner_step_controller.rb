module Steps
  class PartnerStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::PartnerDecisionTree
    end

    def partner
      @partner ||= current_crime_application.partner
    end

    def partner_details
      return @partner_details if @partner_details

      @partner_details = partner.partner_details || partner.build_partner_details
    end
  end
end
