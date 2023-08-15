# :nocov:
class DocumentsController < ApplicationController
  # TODO: this skip TO BE REMOVED -----
  # MOJ multi-upload component XHR request does not propagate the token
  skip_before_action :verify_authenticity_token
  before_action :check_crime_application_presence

  respond_to :html, :json, :js

  def create
    success = Datastore::Documents::Upload.new(
      bundle: current_document_bundle, files: files_from_params
    ).call

    if request.xhr?
      # TODO: better error handling!
      if success
        json = {}
        status = :created
      else
        json = { error: { message: 'Error uploading file' } }
        status = :ok # MOJ component expects a successful response!
      end

      render json:, status:
    else
      redirect_to edit_steps_evidence_upload_path(current_crime_application)
    end
  end

  def download; end

  def destroy; end

  private

  def current_document_bundle
    @current_document_bundle ||= DocumentBundle.find(document_bundle_id)
  end

  # TODO: unify if possible the submission params
  # Currently XHR and HTML requests have different structure
  def files_from_params
    if params.key?(:steps_evidence_upload_form)
      params.fetch(:steps_evidence_upload_form, {}).fetch(:documents)
    else
      params.fetch(:documents)
    end
  end

  def document_bundle_id
    params[:id]
  end

  def application_id
    current_document_bundle.crime_application_id
  end
end
# :nocov:
