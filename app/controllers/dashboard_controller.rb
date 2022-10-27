class DashboardController < ApplicationController
  private

  def present_crime_application
    @crime_application = helpers.present(current_crime_application)
  end
end
