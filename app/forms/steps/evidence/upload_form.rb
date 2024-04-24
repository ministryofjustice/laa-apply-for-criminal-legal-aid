module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      delegate :documents, to: :crime_application

      def prompt
        @prompt ||= ::Evidence::Prompt.new(crime_application).run!
      end

      private

      # :nocov:
      def persist!
        true
      end
      # :nocov:
    end
  end
end
