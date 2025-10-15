module Steps
  class BaseStepController < ApplicationController
    before_action :check_crime_application_presence
    before_action :require_current_office!
    before_action :block_contingent_liability!
    before_action :update_navigation_stack, only: [:show, :edit]
    before_action :set_security_headers

    # :nocov:
    def show
      raise 'implement this action, if needed, in subclasses'
    end

    def edit
      raise 'implement this action, if needed, in subclasses'
    end

    def update
      raise 'implement this action, if needed, in subclasses'
    end
    # :nocov:

    private

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def update_and_advance(form_class, as:, record: nil, flash: nil, **kwargs)
      hash = permitted_params(form_class).to_h
      hash.merge!(kwargs, step_name: as)

      @form_object = form_class.new(
        hash.merge(crime_application: current_crime_application, record: record)
      )

      if params.key?(:commit_draft)
        # Validations will not be run when saving a draft
        @form_object.save!
        redirect_to edit_crime_application_path(current_crime_application)
      elsif @form_object.save
        redirect_to decision_tree_class.new(@form_object, as:).destination, flash:
      else
        render :edit
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def permitted_params(form_class)
      params
        .fetch(form_class.model_name.singular, {})
        .permit(form_class.attribute_names + additional_permitted_params)
    end

    # Some form objects might contain complex attribute structures or nested params.
    # Override in subclasses to declare any additional parameters that should be permitted.
    def additional_permitted_params
      []
    end

    def update_navigation_stack
      return unless current_crime_application

      stack_until_current_page = current_crime_application
                                 .navigation_stack.take_while { |path| path != request.fullpath }

      current_crime_application.update_column(:navigation_stack, stack_until_current_page + [request.fullpath]) # rubocop:disable Rails/SkipsModelValidations
    end

    def current_form_object
      @form_object
    end
    helper_method :current_form_object

    def redirect_cifc
      redirect_to edit_crime_application_path(current_crime_application) if current_crime_application.cifc?
    end
  end
end
