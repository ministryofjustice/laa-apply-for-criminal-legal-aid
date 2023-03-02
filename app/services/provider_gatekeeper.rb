class ProviderGatekeeper
  attr_reader :auth_info, :reason

  def initialize(auth_info)
    @auth_info = auth_info
  end

  # NOTE: this method will be refactored to include some more
  # rules for allowing or not access to providers depending
  # if they've been onboarded into our private MVP, based on
  # office codes, or email address, etc.
  # Until we know more, we just do a very high level check.
  #
  def access_allowed?
    @reason = :no_office_codes if office_codes.blank?
    @reason.blank?
  end

  private

  def office_codes
    auth_info.office_codes
  end
end
