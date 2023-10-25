# module DatastoreApi::Requests::Documents
#   class Delete
#     def call
#       puts '===> MONKEYPATCHED!'
#       raise ArgumentError, 'testing'
#     end
#   end
# end

module Datastore
  module Documents
    class Delete
      attr_reader :document, :current_provider, :request_ip

      def initialize(document:, current_provider:, request_ip:)
        @document = document
        @current_provider = current_provider
        @request_ip = request_ip
      end

      def call
        return true unless deletable?

        Rails.error.handle(fallback: -> { false }, context: context, severity: :error) do
          DatastoreApi::Requests::Documents::Delete.new(object_key:).call
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
        { provider_id: current_provider.id,
          provider_ip: request_ip,
          file_type: document.content_type,
          s3_object_key: object_key }
      end
    end
  end
end
