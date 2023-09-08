# :nocov:
class DocumentsController < ApplicationController
  before_action :check_crime_application_presence

  respond_to :html, :json, :js

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    document = Document.create_from_file(
      file: file_from_params, bundle: current_document_bundle
    )

    Datastore::Documents::Upload.new(document:).call if document.valid?(:criteria)

    location = edit_steps_evidence_upload_path(current_crime_application)

    respond_with(document, location:) do |format|
      if document.errors.any?
        format.html { redirect_to location }
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

  def current_document_bundle
    @current_document_bundle ||= DocumentBundle.find(document_bundle_id)
  end

  # TODO: unify if possible the submission params
  # Currently XHR and HTML requests have different structure
  # Also needs proper error handling for non-JS version if user click
  # upload button without having selected a file
  def file_from_params
    if params.key?(:steps_evidence_upload_form)
      params.fetch(:steps_evidence_upload_form, {}).fetch(:document)
    else
      params.fetch(:document)
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
