module Steps
  module Evidence
    class UploadController < Steps::EvidenceStepController
      def edit
        @form_object = UploadForm.build(
          current_crime_application
        )
      end

      # :nocov:
      def update
        if params[:steps_evidence_upload_form]

        uploaded_files = params[:steps_evidence_upload_form][:upload_files]

        uploaded_files.each do |uploaded_file|
          File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
            file.write(uploaded_file.read)
          end
        end
      end
      # :nocov:

        update_and_advance(UploadForm, as: :upload)
      end
    end
  end
end