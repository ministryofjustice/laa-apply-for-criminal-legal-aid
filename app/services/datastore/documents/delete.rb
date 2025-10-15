module Datastore
  module Documents
    class Delete
      attr_reader :document, :deleted_by, :deletion_reason

      def initialize(document:, deleted_by:, deletion_reason:)
        @document = document
        @deleted_by = deleted_by
        @deletion_reason = deletion_reason
      end

      def call
        return true unless deletable?

        Rails.error.handle(fallback: -> { false }, severity: :error) do
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

      def crime_application
        CrimeApplication.find(document.crime_application_id)
      end

      def log_document_deletion
        DeletionEntry.create!(
          record_id: document.id,
          record_type: RecordType::DOCUMENT.to_s,
          business_reference: crime_application.reference,
          deleted_by: deleted_by,
          reason: deletion_reason
        )
      end
    end
  end
end
