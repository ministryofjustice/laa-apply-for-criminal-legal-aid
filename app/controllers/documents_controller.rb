# :nocov:
class DocumentsController < ApplicationController
  before_action :check_crime_application_presence

  respond_to :html, :json, :js

  def create
    respond_with do |format|
      format.html do
        redirect_to edit_steps_evidence_upload_path
      end
      format.json do
        render json: {}, status: :created
      end
    end
  end

  def download; end

  def destroy; end
end
# :nocov:
