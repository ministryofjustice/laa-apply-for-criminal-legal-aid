module SubmissionSerializer
  module Sections
    class EvidenceDetails < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.evidence_details do
            json.last_run_at(crime_application.evidence_last_run_at) if crime_application.evidence_last_run_at
            json.evidence_prompts(crime_application.evidence_prompts) if crime_application.evidence_prompts
          end
        end
      end
    end
  end
end
