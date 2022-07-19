module Decisions
  class BaseDecisionTree
    class InvalidStep < RuntimeError; end

    attr_reader :form_object, :step_name

    def initialize(form_object, as:)
      @form_object = form_object
      @step_name = as
    end

    private

    # :nocov:
    def show(step_controller, action: :show)
      { controller: step_controller, action: action }
    end

    def edit(step_controller, params = {})
      { controller: step_controller, action: :edit }.merge(params)
    end
    # :nocov:
  end
end
