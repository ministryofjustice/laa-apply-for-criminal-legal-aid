module SubmissionSerializer
  module Sections
    class PostSubmissionEvidence < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.post_submission_evidence Definitions::Document.generate(documents.post_submission_evidence)
          json.pse_notes crime_application.pse_notes
        end
      end

      private

      def documents
        crime_application.documents
      end
    end
  end
end
