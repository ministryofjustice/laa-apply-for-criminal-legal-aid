module Datastore
  module Documents
    class Delete
      attr_reader :document, :log_context

      def initialize(document:, log_context:)
        @document = document
        @log_context = log_context
      end

      def call
        return true unless deletable?

        Rails.error.handle(fallback: -> { false }, context: context, severity: :error) do
          DatastoreApi::Requests::Documents::Delete.new(object_key:).call
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
      end
    end
  end
end
