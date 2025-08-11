# :nocov:
class DocumentsController < ApplicationController
  before_action :check_crime_application_presence
  before_action :set_document, only: :download
  before_action :require_document
  before_action :set_security_headers

  respond_to :html, :json, :js

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    document = Document.create_from_file(
      file: file_from_params, crime_application: current_crime_application
    )

    Datastore::Documents::Upload.new(document:, log_context:).call if document.valid?(:criteria)

    document.url = download_crime_application_document_path(current_crime_application, document)

    respond_with(document, location: evidence_upload_step) do |format|
      if document.invalid?(:storage) || document.invalid?(:scan)
        format.html { redirect_to evidence_upload_step }
        format.json do
          render json: document.as_json.merge(error_message: error_for(document)),
                 status: :unprocessable_entity
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def download
    presign_download = Datastore::Documents::Download.new(document: @document, log_context: log_context).call

    unless presign_download
      raise Errors::DocumentUnavailable,
            "Could not download `#{@document.filename}` with object_key: `#{@document.s3_object_key}`"
    end

    redirect_to(presign_download.url, allow_other_host: true)
  end

  def destroy; end

  private

  def set_document
    @document = current_crime_application.documents.find(params[:document_id])
  rescue ActiveRecord::RecordNotFound
    raise Errors::DocumentUnavailable, 'CrimeApplication/Document mismatch'
  end

  def log_context
    LogContext.new(current_provider: current_provider, ip_address: request.remote_ip)
  end

  def evidence_upload_step
    edit_steps_evidence_upload_path(current_crime_application)
  end

  # Handles scenario where user clicks upload button without having selected a file to upload on non-JS form
  # Needs to be handled in future with an appropriate error message but this is not easily feasible with current setup
  def require_document
    return if params.key?(:document) || params.key?(:document_id) || params.key?(:steps_evidence_upload_form)

    redirect_to evidence_upload_step
  end

  def error_for(document)
    return nil if document.errors.empty?

    document.errors.first.full_message
  end

  # TODO: unify if possible the submission params
  # Currently XHR and HTML requests have different structure
  def file_from_params
    if params.key?(:steps_evidence_upload_form)
      params.fetch(:steps_evidence_upload_form, {}).fetch(:document)
    else
      params.fetch(:document)
    end
  end
end
# :nocov:
