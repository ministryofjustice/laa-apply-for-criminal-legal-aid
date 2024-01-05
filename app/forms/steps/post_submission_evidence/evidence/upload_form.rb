module Steps
  module PostSubmissionEvidence
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
end
