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
        # the upload page is not part of the flow yet so document bundles may not be initialised
        if crime_application.document_bundles.first.nil?
          @documents = {}
        else
          # we only want documents successfully uploaded to s3 to be serialised
          @documents ||= crime_application.document_bundles.first.documents.uploaded_to_s3
        end
      end
    end
  end
end
