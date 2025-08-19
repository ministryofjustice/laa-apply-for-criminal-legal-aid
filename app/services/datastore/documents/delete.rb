module Datastore
  module Documents
    class Delete
      attr_reader :document, :log_context, :current_provider

      def initialize(document:, log_context:, current_provider:)
        @document = document
        @log_context = log_context
        @current_provider = current_provider
      end

      def call
        return true unless deletable?

        Rails.error.handle(fallback: -> { false }, context: context, severity: :error) do
          DatastoreApi::Requests::Documents::Delete.new(object_key:).call
          log_document_deletion
          Rails.logger.info "Document successfully deleted. Object key: #{document.s3_object_key}"
          true
        end
      end

      private

      # If document has been submitted, protect against hard deletions
      # If object is not stored, there is nothing to delete
      def deletable?
        object_key.present? && document.submitted_at.nil?
      end

      def object_key
        document.s3_object_key
      end

      def context
        log_context << { file_type: document.content_type, s3_object_key: object_key }
        log_context.to_h
      end

      def crime_application
        CrimeApplication.find(document.crime_application_id)
      end

      def log_document_deletion
        DeletionEntry.create!(
          record_id: document.id,
          record_type: RecordType::DOCUMENT.to_s,
          business_reference: crime_application.reference,
          deleted_by: current_provider ? current_provider.id : 'system_automated',
          reason: current_provider ? DeletionReason::PROVIDER_ACTION.to_s : DeletionReason::RETENTION_RULE.to_s
        )
      end
    end
  end
end
