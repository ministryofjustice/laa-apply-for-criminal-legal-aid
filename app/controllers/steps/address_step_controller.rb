module Steps
  class AddressStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::AddressDecisionTree
    end

    def address_record
      @address_record ||= current_crime_application.addresses.find(params.expect(:address_id))
    end
  end
end
