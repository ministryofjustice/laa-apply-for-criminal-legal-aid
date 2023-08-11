module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject

      private

      # :nocov:
      def persist!
        crime_application.update(
          attributes
        )
      end
      # :nocov:

    end
  end
end
