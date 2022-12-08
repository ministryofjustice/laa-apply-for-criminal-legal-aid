module AuthHandling
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_user!
    helper_method :warden, :signed_in?, :current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user
    warden.user
  end

  def warden
    request.env['warden']
  end

  protected

  def authenticate_user!
    warden.authenticate!
  end
end
