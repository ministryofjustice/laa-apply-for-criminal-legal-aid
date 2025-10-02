class ErrorsController < UnauthenticatedController
  def invalid_session
    respond_with_status(:ok)
  end

  def invalid_token
    respond_with_status(:bad_request)
  end

  def application_not_found
    respond_with_status(:not_found)
  end

  def not_found
    respond_with_status(:not_found)
  end

  def unauthenticated
    respond_with_status(:ok)
  end

  def reauthenticate
    respond_with_status(:ok)
  end

  def account_locked
    respond_with_status(:ok)
  end

  def not_enrolled
    respond_with_status(:forbidden)
  end

  def unhandled
    respond_with_status(:internal_server_error)
  end

  def contingent_liability
    respond_with_status(:forbidden)
  end

  private

  def respond_with_status(status)
    respond_to do |format|
      format.html { render status: }
      format.all  { head status, content_type: 'text/plain' }
    end
  end
end
