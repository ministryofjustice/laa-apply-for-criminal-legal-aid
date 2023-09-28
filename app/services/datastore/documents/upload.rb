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

        # TODO: PoC - move this to a separate service object
        # On scan, annotate document with `infected`, `clean`, etc.
        # return false if Clamby.virus?(document.tempfile.path)

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
        document.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end
    end
  end
end
