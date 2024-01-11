module SubmissionSerializer
  module Sections
    class PostSubmissionEvidence < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.supporting_evidence Definitions::Document.generate(documents.stored)
          json.notes crime_application.notes
        end
      end

      private

      def documents
        crime_application.documents
      end
    end
  end
end
