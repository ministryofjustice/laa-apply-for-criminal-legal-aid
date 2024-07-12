module Decisions
  class CircumstancesDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :appeal_reference_number
        start_client_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def start_client_details
      if FeatureFlags.non_means_tested.enabled?
        edit('/steps/client/is_means_tested')
      else
        edit('/steps/client/details')
      end
    end
  end
end
