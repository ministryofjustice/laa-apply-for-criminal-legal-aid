module Decisions
  module PostSubmissionEvidence
    class EvidenceDecisionTree < BaseDecisionTree
      def destination
        case step_name
        when :delete_document
          edit(:upload)
        when :upload_finished
          edit('/steps/post_submission_evidence/submission/review')
        else
          raise InvalidStep, "Invalid step '#{step_name}'"
        end
      end
    end
  end
end
