# This module gets mixed in and extends the helpers already provided by
# `GOVUKDesignSystemFormBuilder::FormBuilder`. These are app-specific
# form helpers so can be coupled to application business and logic.
#
module FormBuilderHelper
  def continue_button(primary: :save_and_continue, secondary: :save_and_come_back_later,
                      primary_opts: {}, secondary_opts: {})
    submit_button(primary, primary_opts.merge(data: { 'main-action': true })) do
      submit_button(secondary, secondary_opts.merge(secondary: true, name: 'commit_draft')) if secondary
    end
  end

  def date_input(attribute_name, opts = {}, &block)
    combined_error_message = DateFieldErrors.joined_inline_message(object, attribute_name)

    return govuk_date_field(attribute_name, segments:, segment_names:, **opts, &block) unless combined_error_message

    with_inline_error_message(attribute_name, combined_error_message) do
      govuk_date_field(attribute_name, segments:, segment_names:, **opts, &block)
    end
  end

  # Overrides the GOV.UK form builder's govuk_number_field to inject a
  # visually hidden "Amount in pounds" span into the label when prefix_text
  # is '£'. This ensures screen reader users receive the same currency context
  # that sighted users get from the visible pound symbol prefix.
  def govuk_number_field(attribute_name, prefix_text: nil, label: {}, **, &block)
    label = label_with_currency_hint(attribute_name, label) if prefix_text == '£' && label.is_a?(Hash)

    super
  end

  private

  def with_inline_error_message(attribute_name, message)
    errors = object.errors
    return yield if errors.where(attribute_name).blank?

    with_restored_errors(errors) do
      errors.delete(attribute_name)
      errors.add(attribute_name, message)
      yield
    end
  end

  def with_restored_errors(errors)
    original_errors = errors.dup
    yield
  ensure
    errors.copy!(original_errors)
  end

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
  end

  def label_with_currency_hint(attribute_name, label_opts)
    label_text = label_opts[:text] ||
                 I18n.t("helpers.label.#{object_name}.#{attribute_name}", default: nil) ||
                 attribute_name.to_s.humanize

    hidden_span = content_tag(:span, I18n.t('helpers.currency_input_hint'),
                              class: 'govuk-visually-hidden')
    label_opts.merge(text: safe_join([label_text, hidden_span], ' '))
  end

  def segment_names
    { day: I18n.t('date.day'), month: I18n.t('date.month'), year: I18n.t('date.year') }
  end

  # This ensures that the month segment is not automatically cast to integer by the form class,
  # allowing month names to be entered.
  def segments
    { day: '3i', month: '2', year: '1i' }
  end
end
