module Summary
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def show?
        true
      end

      def answers
        [
          documents.map do |document|
            next if document.s3_object_key.nil?

            Components::FreeTextAnswer.new(
              :supporting_evidence, document.filename,
              change_path: edit_steps_evidence_upload_path(crime_application)
            )
          end
        ].flatten.compact.select(&:show?)
      end

      def change_path
        return unless documents.empty?

        edit_steps_evidence_upload_path
      end

      private

      def documents
        @documents ||= crime_application.documents
      end
    end
  end
end
