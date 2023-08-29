module Datastore
  module Documents
    class Upload
      attr_accessor :bundle, :files

      PRESIGNED_URL_EXPIRES_IN = 15 # seconds

      def initialize(bundle:, files:)
        @bundle = bundle
        @files = Array(files)
      end

      # TODO: terribly ugly PoC code, to be refactored,
      # proper error handling, logging, etc.
      def call
        results = []

        files.each do |file|
          object_key = nil
          response = DatastoreApi::Requests::Documents::PresignUpload.new(usn:, expires_in:).call

          object_key = response.object_key if upload_to_s3(response.url, file)

          bundle.documents.create(
            s3_object_key: object_key,
            filename: file.original_filename,
            content_type: file.content_type,
            file_size: file.tempfile.size,
          )

          results << object_key.present?
        end

        results.all?(true)
      end

      private

      # This might be best shifted to the DatastoreAPI
      # as another S3 operation
      def upload_to_s3(url, file)
        Rails.error.handle(fallback: -> { false }) do
          headers = { content_type: file.content_type, content_length: file.tempfile.size.to_s }
          resp = Faraday.put(url, file.tempfile, headers)
          resp.success?
        end
      end

      def usn
        bundle.crime_application.usn
      end

      def expires_in
        PRESIGNED_URL_EXPIRES_IN
      end
    end
  end
end
