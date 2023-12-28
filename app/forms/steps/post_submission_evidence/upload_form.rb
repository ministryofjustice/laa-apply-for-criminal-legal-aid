module Steps
  module PostSubmissionEvidence
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
