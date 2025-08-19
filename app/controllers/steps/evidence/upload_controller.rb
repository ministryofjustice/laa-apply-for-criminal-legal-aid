module Steps
  module Evidence
    class UploadController < Steps::EvidenceStepController
      def edit
        @form_object = UploadForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(UploadForm, as: step_name, flash: @flash)
      end

      private

      def step_name
        return :upload_finished unless params.key?('document_id')

        document = current_crime_application.documents.find(params['document_id'])

        if Datastore::Documents::Delete.new(document:, log_context:, current_provider:).call
          @flash = { success: t('steps.evidence.upload.edit.delete.success', file_name: document.filename) }
          document.destroy
        else
          @flash = { alert: t('steps.evidence.upload.edit.delete.failure', file_name: document.filename) }
        end

        :delete_document
      end

      def log_context
        LogContext.new(current_provider: current_provider, ip_address: request.remote_ip)
      end
    end
  end
end
