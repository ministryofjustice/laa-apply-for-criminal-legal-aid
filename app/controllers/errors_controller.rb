class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def invalid_session
    respond_with_status(:ok)
  end

  def application_not_found
    respond_with_status(:not_found)
  end

  def not_found
    respond_with_status(:not_found)
  end

  def unhandled
    respond_with_status(:internal_server_error)
  end

  private

  def respond_with_status(status)
    respond_to do |format|
      format.html { render status: status }
      format.all  { head status }
    end
  end
end
