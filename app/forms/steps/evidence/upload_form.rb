module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      delegate :documents, to: :crime_application

      def prompt
        @prompt ||= ::Evidence::RulesRunner.new(crime_application).prompt
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
