class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                     :authenticate_provider!

  def invalid_session
    respond_with_status(:ok)
  end

  def application_not_found
    respond_with_status(:not_found)
  end

  def not_found
    respond_with_status(:not_found)
  end

  def unauthorized
    respond_with_status(:unauthorized)
  end

  def not_enrolled
    respond_with_status(:forbidden)
  end

  def unhandled
    respond_with_status(:internal_server_error)
  end

  private

  def respond_with_status(status)
    respond_to do |format|
      format.html { render status: }
      format.all  { head status }
    end
  end
end
