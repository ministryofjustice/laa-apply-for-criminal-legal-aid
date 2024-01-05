module Steps
  module PostSubmissionEvidence
    class EvidenceStepController < BaseStepController
      private

      def decision_tree_class
        Decisions::PostSubmissionEvidence::EvidenceDecisionTree
      end
    end
  end
end
