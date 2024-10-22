module Summary
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def show?
        true
      end

      def answers
        if submitted_documents?
          [
            documents.map do |document|
              next if document.s3_object_key.nil?

              Components::FreeTextAnswer.new(
                :supporting_evidence, document.filename,
                change_path: edit_steps_evidence_upload_path(crime_application)
              )
            end
          ].flatten.compact.select(&:show?)
        else
          [
            Components::FreeTextAnswer.new(
              :no_supporting_evidence, nil
            )
          ]
        end
      end

      def change_path
        return unless documents.empty?

        edit_steps_evidence_upload_path
      end

      def heading
        :supporting_evidence
      end

      def name
        :files
      end

      private

      def documents
        @documents ||= crime_application.documents
      end

      def submitted_documents?
        documents.any?
      end
    end
  end
end
