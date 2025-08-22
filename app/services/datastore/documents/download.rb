module Datastore
  module Documents
    class Download
      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_accessor :document

      def initialize(document:)
        @document = document
      end

      def call
        Rails.error.handle(fallback: -> { false }, severity: :error) do
          DatastoreApi::Requests::Documents::PresignDownload.new(
            object_key:, expires_in:, response_content_disposition:
          ).call
        end
      end

      private

      def object_key
        @document.s3_object_key
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end

      def response_content_disposition
        # To force download of file rather than opening in another window
        %(attachment; filename="#{@document.filename}")
      end
    end
  end
end
