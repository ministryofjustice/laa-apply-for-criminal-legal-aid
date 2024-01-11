module SubmissionSerializer
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def to_builder
        Jbuilder.new do |json|
          json.supporting_evidence Definitions::Document.generate(documents.stored)
        end
      end

      private

      def documents
        crime_application.documents
      end
    end
  end
end
