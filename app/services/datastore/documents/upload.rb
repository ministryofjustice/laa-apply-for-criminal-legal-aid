module Datastore
  module Documents
    class Upload
      class UnsuccessfulUploadError < StandardError; end

      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_reader :document, :presign_upload

      def initialize(document:)
        @document = document
        @presign_upload = nil
      end

      def call
        return false if document.s3_object_key.present?

        Rails.error.handle(fallback: -> { false }, severity: :error) do
          scan
          set_presign_upload
          upload_to_s3(@presign_upload&.url)
          persist_document(@presign_upload&.object_key)

          true
        end
      end

      private

      def scan
        virus_scan = Scan.new(document:)
        virus_scan.call

        return if virus_scan.success?

        raise UnsuccessfulUploadError, t(:scan_inconclusive) if virus_scan.inconclusive?

        args = {
          crime_application_id: document.crime_application_id,
          document_id: document.id,
          scan_status: document.scan_status,
        }

        raise UnsuccessfulUploadError, t(:scan_flagged, **args)
      end

      def persist_document(s3_object_key)
        raise UnsuccessfulUploadError, 'S3 Object Key missing' if s3_object_key.blank?

        document.update(s3_object_key:)
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

        Rails.logger.info t(:success, s3_object_key: document.s3_object_key)
      end

      def usn
        document.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end

      def t(key, **args)
        I18n.t("steps.evidence.upload.#{key}", **args)
      end
    end
  end
end
