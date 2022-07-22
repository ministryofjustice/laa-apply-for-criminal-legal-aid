module Steps
  class BaseStepController < ApplicationController
    before_action :check_crime_application_presence
    before_action :update_navigation_stack, only: [:show, :edit]

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
    def update_and_advance(form_class, opts = {})
      hash = permitted_params(form_class).to_h
      record = opts[:record]

      @form_object = form_class.new(
        hash.merge(crime_application: current_crime_application, record: record)
      )

      if params.key?(:commit_draft)
        # Validations will not be run when saving a draft
        @form_object.save!
        redirect_to root_path # TODO: this will go to the task list
      elsif @form_object.save
        redirect_to decision_tree_class.new(@form_object, as: opts.fetch(:as)).destination
      else
        render opts.fetch(:render, :edit)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def permitted_params(form_class)
      params
        .fetch(form_class.model_name.singular, {})
        .permit(form_attribute_names(form_class))
    end

    def form_attribute_names(form_class)
      form_class.attribute_types.map do |(attr_name, primitive)|
        primitive.is_a?(ActiveModel::Type::Date) ? date_params(attr_name) : attr_name
      end.flatten
    end

    # TODO: migrate to new format:
    # {'dob(1i)' => '2008', 'dob(2i)' => '11', 'dob(3i)' => '22'}
    # :nocov:
    def date_params(attr_name)
      %W[#{attr_name}_dd #{attr_name}_mm #{attr_name}_yyyy]
    end
    # :nocov:

    def update_navigation_stack
      return unless current_crime_application

      stack_until_current_page = current_crime_application
                                 .navigation_stack.take_while { |path| path != request.fullpath }

      current_crime_application.navigation_stack = stack_until_current_page + [request.fullpath]
      current_crime_application.save!(touch: false)
    end
  end
end
