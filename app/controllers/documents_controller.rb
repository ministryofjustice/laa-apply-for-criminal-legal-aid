# :nocov:
class DocumentsController < ApplicationController
  before_action :check_crime_application_presence
  before_action :require_document

  respond_to :html, :json, :js

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    document = Document.create_from_file(
      file: file_from_params, crime_application: current_crime_application
    )

    Datastore::Documents::Upload.new(document:, current_provider:, request_ip:).call if document.valid?(:criteria)

    respond_with(document, location: evidence_upload_step) do |format|
      if document.invalid?(:storage)
        format.html { redirect_to evidence_upload_step }
        format.json do
          render json: document.as_json.merge(error_message: document.errors.first.full_message),
                 status: :unprocessable_entity
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def download; end

  def destroy; end

  private

  def request_ip
    request.remote_ip
  end

  def evidence_upload_step
    edit_steps_evidence_upload_path(current_crime_application)
  end

  # Handles scenario where user clicks upload button without having selected a file to upload on non-JS form
  # Needs to be handled in future with an appropriate error message but this is not easily feasible with current setup
  def require_document
    redirect_to evidence_upload_step unless params.key?(:document) || params.key?(:steps_evidence_upload_form)
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
