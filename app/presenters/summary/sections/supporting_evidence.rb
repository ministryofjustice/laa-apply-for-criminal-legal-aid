module Summary
  module Sections
    class SupportingEvidence < Sections::BaseSection
      def show?
        documents.present? && super
      end

      def answers
        all_answers.select(&:show?)
      end

      private

      def all_answers
        return document_answers unless FeatureFlags.additional_information.enabled?

        document_answers << additional_information_answer
      end

      def document_answers
        documents.map do |document|
          Components::FreeTextAnswer.new(
            :supporting_evidence, document.filename,
            change_path: edit_steps_evidence_upload_path(crime_application),
            show: document.s3_object_key.nil?
          )
        end
      end

      def additional_information_answer
        Components::FreeTextAnswer.new(
          :additional_information,
          crime_application.additional_information,
          show: true,
          change_path: edit_steps_evidence_additional_information_path(crime_application)
        )
      end

      def documents
        @documents ||= crime_application.documents
      end
    end
  end
end
