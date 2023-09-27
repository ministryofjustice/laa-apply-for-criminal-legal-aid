module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      # :nocov:
      def documents
        crime_application.documents.not_deleted
      end

      private

      def persist!
        true
      end
      # :nocov:
    end
  end
end
