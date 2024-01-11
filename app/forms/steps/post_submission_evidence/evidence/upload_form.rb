module Steps
  module PostSubmissionEvidence
    module Evidence
      class UploadForm < Steps::BaseFormObject
        delegate :documents, to: :crime_application

        attribute :pse_notes, :string

        private

        def persist!
          crime_application.update(
            attributes
          )
        end
      end
    end
  end
end
