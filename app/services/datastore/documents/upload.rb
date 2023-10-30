module Datastore
  module Documents
    class Upload
      class UnsuccessfulUploadError < StandardError; end

      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_reader :document, :log_context, :presign_upload

      def initialize(document:, log_context:)
        @document = document
        @log_context = log_context
        @presign_upload = nil
      end

      # TODO: 2023-10-6 document is persisted regardless of scan
      # result due to incomplete UX
      def call
        return false if document.s3_object_key.present?

        Rails.error.handle(fallback: -> { false }, context: context, severity: :error) do
          scan
          set_presign_upload
          upload_document

          true
        end
      end

      private

      def scan
        Scan.new(document:).call
      end

      def upload_document
        document.update(s3_object_key: @presign_upload&.object_key) if upload_to_s3(@presign_upload&.url)
      end

      def set_presign_upload
        @presign_upload = DatastoreApi::Requests::Documents::PresignUpload.new(
          usn:, expires_in:
        ).call

        raise UnsuccessfulUploadError, 'Error retrieving presign upload url' unless @presign_upload&.url
        raise UnsuccessfulUploadError, 'Object Key missing' unless @presign_upload&.object_key
      end

      def upload_to_s3(url)
        headers = {
          content_type: document.content_type,
          content_length: document.file_size.to_s,
        }

        response = Faraday.put(
          url, document.tempfile, headers
        )

        raise UnsuccessfulUploadError, response.body unless response.success?

        Rails.logger.info "Document successfully uploaded. Object key: #{document.s3_object_key}"
      end

      def usn
        document.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end

      def context
        log_context << { file_type: document.content_type }
      end
    end
  end
end
