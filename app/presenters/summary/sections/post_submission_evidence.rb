module Summary
  module Sections
    class PostSubmissionEvidence < Sections::BaseSection
      def show?
        documents.present? && super
      end

      def answers
        [
          documents.map do |document|
            next if document.s3_object_key.nil?

            Components::FreeTextAnswer.new(
              :post_submission_evidence, document.filename,
              change_path:
            )
          end,
          Components::FreeTextAnswer.new(
            :notes, crime_application.notes,
            change_path:
          )
        ].flatten.compact.select(&:show?)
      end

      private

      def change_path
        edit_steps_post_submission_evidence_evidence_upload_path(crime_application)
      end

      def documents
        @documents ||= crime_application.documents
      end
    end
  end
end
