module Decisions
  class BaseDecisionTree
    class InvalidStep < RuntimeError; end

    attr_reader :form_object, :step_name

    def initialize(form_object, as:)
      @form_object = form_object
      @step_name = as
    end

    def current_crime_application
      form_object.crime_application
    end

    private

    def partner
      @partner ||= current_crime_application.partner
    end

    # :nocov:
    def show(step_controller, params = {})
      url_options(step_controller, :show, params)
    end

    def edit(step_controller, params = {})
      url_options(step_controller, :edit, params)
    end

    def url_options(controller, action, params = {})
      { controller: controller, action: action, id: current_crime_application }.merge(params)
    end

    # :nocov:
  end
end
