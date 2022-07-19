module StartingPointStep
  extend ActiveSupport::Concern

  private

  def current_crime_application
    # Only the step including this concern should create a new case
    # if there isn't one in the session - because it's the first
    super || initialize_crime_application
  end

  def update_navigation_stack
    # The step including this concern will reset the navigation stack
    # before re-initialising it in `BaseStepController#update_navigation_stack`
    current_crime_application.navigation_stack = []
    super
  end
end
