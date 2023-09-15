module Steps
  module Evidence
    class UploadController < Steps::EvidenceStepController
      def edit
        @form_object = UploadForm.build(
          document_bundle_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(UploadForm, record: document_bundle_record, as: :upload)
      end
    end
  end
end
