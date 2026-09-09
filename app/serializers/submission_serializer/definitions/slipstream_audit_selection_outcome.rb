module SubmissionSerializer
  module Definitions
    class SlipstreamAuditSelectionOutcome < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.status status
          json.sample_rate sample_rate
          json.sampled_at sampled_at
          json.status_determined_at status_determined_at
        end
      end
    end
  end
end
