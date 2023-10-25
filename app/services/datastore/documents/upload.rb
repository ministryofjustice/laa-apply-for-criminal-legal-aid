# module DatastoreApi::Requests::Documents
#   class PresignUpload
#     def call
#       puts '===> MONKEYPATCHED!'
#       false
#     end
#   end
# end

module Datastore
  module Documents
    class Upload
      class UnsuccessfulUploadError < StandardError; end

      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      attr_reader :document, :current_provider, :s3_object_key, :request_ip

      def initialize(document:, current_provider:, request_ip:)
        @document = document
        @current_provider = current_provider
        @request_ip = request_ip
        @s3_object_key = nil
      end

      # TODO: 2023-10-6 document is persisted regardless of scan
      # result due to incomplete UX
      def call # rubocop:disable Metrics/AbcSize
        return false if document.s3_object_key.present?

        Rails.error.handle(fallback: -> { false }, context: context, severity: :error) do
          Scan.new(document:).call

          presign_upload = DatastoreApi::Requests::Documents::PresignUpload.new(
            usn:, expires_in:
          ).call

          unless presign_upload.present? && presign_upload.key?('url')
            raise UnsuccessfulUploadError, 'Error retrieving presign upload url'
          end

          @s3_object_key = presign_upload.object_key

          document.update(s3_object_key:) if upload_to_s3(presign_upload.url)
        end
      end

      private

      # def presign_upload
      #   presign_upload = DatastoreApi::Requests::Documents::PresignUpload.new(
      #     usn:, expires_in:
      #   ).call
      #
      #   unless presign_upload.present? && presign_upload.key?('url')
      #     raise UnsuccessfulUploadError, 'Error retrieving presign upload url'
      #   end
      #
      #   presign_upload
      # end

      def upload_to_s3(url)
        headers = {
          content_type: document.content_type,
          content_length: document.file_size.to_s,
        }

        response = Faraday.put(
          url, document.tempfile, headers
        )

        raise UnsuccessfulUploadError, response.body unless response.success?

        Rails.logger.info "Document successfully uploaded - #{document.s3_object_key}"
      end

      def usn
        document.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end

      def context
        { provider_id: current_provider.id,
          provider_ip: request_ip,
          file_type: document.content_type,
          s3_object_key: s3_object_key }
      end
    end
  end
end
