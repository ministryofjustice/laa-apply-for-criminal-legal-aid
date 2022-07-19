module ViewSpecHelpers
  module ControllerViewHelpers
    def current_crime_application
      raise 'Stub `current_crime_application` if you want to test its behavior.'
    end
  end

  def initialize_view_helpers(view)
    view.extend ControllerViewHelpers
  end
end
