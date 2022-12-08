class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:create]

  # This is the callback endpoint
  def create
    authenticate_user!
    redirect_to crime_applications_path
  end

  def destroy
    warden.logout
    redirect_to root_path
  end

  def failure
    redirect_to root_path, flash: { notice: t('errors.omniauth.signin_failure') }
  end
end
