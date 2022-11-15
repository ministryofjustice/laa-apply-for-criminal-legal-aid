module StepsHelper
  # Render a form_for tag pointing to the update action of the current controller
  def step_form(record, options = {}, &block)
    opts = {
      url: { controller: controller.controller_path, action: :update },
      method: :put
    }.merge(options)

    # Support appending optional css classes, maintaining the default ones
    opts.merge!(
      html: { class: dom_class(record, :edit) }
    ) do |_key, old_value, new_value|
      { class: old_value.values | new_value.values }
    end

    form_for record, opts, &block
  end

  def step_header(path: nil)
    render partial: 'layouts/step_header', locals: {
      path: path || previous_step_path
    }
  end

  def previous_step_path
    # Second to last element in the array, will be nil for arrays of size 0 or 1
    current_crime_application&.navigation_stack&.slice(-2) || root_path
  end

  def govuk_error_summary(form_object)
    return if form_object.try(:errors).blank?

    # Prepend to page title so screen readers read it out as soon as possible
    content_for(:page_title, flush: true) do
      content_for(:page_title).insert(0, t('errors.page_title_prefix'))
    end

    fields_for(form_object, form_object) do |f|
      f.govuk_error_summary t('errors.error_summary.heading')
    end
  end

  # rubocop:disable Metrics/MethodLength
  def link_button(name, href, options = {}, &block)
    html_options = {
      class: 'govuk-button', role: 'button', draggable: false, data: { module: 'govuk-button' },
    }.merge(options) do |_key, old_value, new_value|
      if new_value.is_a?(String) || new_value.is_a?(Array)
        # For strings or array attributes, merge (union) both values
        Array(old_value) | Array(new_value)
      else
        # For other attributes do not merge, override (i.e. draggable and data)
        new_value
      end
    end

    if block
      link_to href, html_options do
        yield(block)
      end
    else
      link_to name, href, html_options
    end
  end
  # rubocop:enable Metrics/MethodLength
end
