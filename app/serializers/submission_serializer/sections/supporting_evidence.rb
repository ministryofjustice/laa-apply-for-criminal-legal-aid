module SubmissionSerializer
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.supporting_evidence Definitions::Document.generate(documents)
        end
      end

      private

      def documents
        # only require the first bundle as we are not supporting resubmitted applications yet
        @documents ||= crime_application.document_bundles.first.documents
      end
    end
  end
end
