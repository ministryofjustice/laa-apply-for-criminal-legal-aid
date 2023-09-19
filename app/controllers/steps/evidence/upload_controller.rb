module Steps
  module Evidence
    class UploadController < Steps::EvidenceStepController
      def edit
        @form_object = UploadForm.build(
          document_bundle_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(UploadForm, record: document_bundle_record, as: step_name, flash: @flash)
      end

      def step_name
        if params.key?('document_id')
          object_key = "#{current_crime_application.usn}/#{params['document_id']}"

          if Datastore::Documents::Delete.new(object_key:).call
            Document.destroy(params['document_id'])
            @flash = { success: t('steps.evidence.upload.edit.delete.success') }
          else
            @flash = { alert: t('steps.evidence.upload.edit.delete.failure') }
          end

          :delete_document
        else
          :upload_finished
        end
      end
    end
  end
end
