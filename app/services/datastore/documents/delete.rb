module Datastore
  module Documents
    class Delete
      attr_reader :document

      def initialize(document:)
        @document = document
      end

      def call
        return true unless deletable?

        Rails.error.handle(fallback: -> { false }) do
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
    end
  end
end
