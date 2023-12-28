module PostSubmissionEvidence
  class UploadController < Steps::EvidenceStepController
    def edit
      @form_object = UploadForm.build(
        current_crime_application
      )
    end

    def update
      update_and_advance(UploadForm, as: step_name, flash: @flash)
    end

    def recreate
      usn = current_crime_application.reference

      # There can only be one application in progress with same USN
      crime_application = CrimeApplication.find_by(usn:) || initialize_crime_application(usn:)

      Datastore::ApplicationRehydration.new(
        crime_application, parent: current_crime_application
      ).call

      # Redirect to the check your answers (review) page
      # of the newly created application
      redirect_to edit_steps_submission_review_path(crime_application)
    end

    private

    def step_name
      return :upload_finished unless params.key?('document_id')

      document = current_crime_application.documents.find(params['document_id'])

      if Datastore::Documents::Delete.new(document:, log_context:).call
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
