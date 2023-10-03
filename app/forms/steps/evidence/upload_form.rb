module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      delegate :documents, to: :crime_application

      private

      # :nocov:
      def persist!
        true
      end
      # :nocov:
    end
  end
end
