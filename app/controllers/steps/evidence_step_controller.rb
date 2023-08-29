module Steps
  class EvidenceStepController < BaseStepController
    private

    def decision_tree_class
      Decisions::EvidenceDecisionTree
    end

    def document_bundle_record
      @document_bundle_record ||= existing_bundles.find_or_initialize_by(submitted_at: nil).tap(&:save)
    end

    def existing_bundles
      current_crime_application.document_bundles
    end
  end
end
