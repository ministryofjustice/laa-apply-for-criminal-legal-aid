class UnauthenticatedController < ApplicationController
  skip_before_action :authenticate_provider!
end
