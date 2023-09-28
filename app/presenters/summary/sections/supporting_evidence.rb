module Summary
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def name
        :supporting_evidence
      end

      def show?
        crime_application.documents.present? && super
      end

      def answers
        [
          documents.map.with_index(1) do |document, index|
            next if document.s3_object_key.nil?

            Components::FreeTextAnswer.new(
              'supporting_evidence', document.filename,
              change_path: change_path,
              i18n_opts: { index: }
            )
          end
        ].flatten.compact.select(&:show?)
      end

      private

      def change_path
        edit_steps_evidence_upload_path(crime_application)
      end

      def documents
        @documents ||= crime_application.documents
      end
    end
  end
end
