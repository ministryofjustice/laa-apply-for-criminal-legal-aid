module Summary
  module Sections
    class PostSubmissionEvidence < Sections::BaseSection
      def show?
        pse.present? && super
      end

      def answers
        [
          pse.map do |document|
            next if document.s3_object_key.nil?

            Components::FreeTextAnswer.new(
              :post_submission_evidence, document.filename,
              change_path:
            )
          end,
          Components::FreeTextAnswer.new(
            :pse_notes, crime_application.pse_notes,
            change_path:
          )
        ].flatten.compact.select(&:show?)
      end

      private

      def change_path
        edit_steps_post_submission_evidence_evidence_upload_path(crime_application)
      end

      def pse
        @pse ||= crime_application.pse
      end
    end
  end
end
