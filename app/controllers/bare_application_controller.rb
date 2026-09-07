# rubocop:disable-next Rails/ApplicationController
class BareApplicationController < ActionController::Base
  # Inherit from this controller for actions that need to be outside
  # Authentication for the application. For instance 'healthcheck' endpoints
  #
end
