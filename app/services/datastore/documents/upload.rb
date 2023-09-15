module Datastore
  module Documents
    class Upload
      class UnsuccessfulUploadError < StandardError; end

      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_accessor :document

      def initialize(document:)
        @document = document
      end

      def call
        return false if document.s3_object_key.present?

        Rails.error.handle(fallback: -> { false }) do
          presign_upload = DatastoreApi::Requests::Documents::PresignUpload.new(
            usn:, expires_in:
          ).call

          if upload_to_s3(presign_upload.url)
            document.update(
              s3_object_key: presign_upload.object_key
            )
          end
        end
      end

      private

      def upload_to_s3(url)
        headers = {
          content_type: document.content_type,
          content_length: document.file_size.to_s,
        }

        response = Faraday.put(
          url, document.tempfile, headers
        )

        response.success? || (raise UnsuccessfulUploadError, response.body)
      end

      def usn
        document.document_bundle.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end
    end
  end
end
