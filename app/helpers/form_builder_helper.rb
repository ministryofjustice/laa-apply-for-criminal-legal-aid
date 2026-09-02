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

  # Overrides the GOV.UK form builder's radio button and check box helpers to
  # inject visually hidden context into the label when the control reveals
  # conditional content (i.e. is called with a block). Screen readers do not
  # reliably announce `aria-expanded` on radios and checkboxes, so this text
  # tells users that selecting the option reveals additional fields. The
  # `aria-expanded` attribute is intentionally left in place. See CRIMAPP-2138.
  def govuk_radio_button(attribute_name, value, label: {}, **, &block)
    label = label_with_conditional_reveal_hint(attribute_name, value, label) if block && label.is_a?(Hash)

    super
  end

  def govuk_check_box(attribute_name, value, unchecked_value = false, label: {}, **, &block) # rubocop:disable Style/OptionalBooleanParameter
    label = label_with_conditional_reveal_hint(attribute_name, value, label) if block && label.is_a?(Hash)

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
                 localised_label(attribute_name) ||
                 attribute_name.to_s.humanize

    hidden_span = content_tag(:span, I18n.t('helpers.currency_input_hint'),
                              class: 'govuk-visually-hidden')
    label_opts.merge(text: safe_join([label_text, hidden_span], ' '))
  end

  # Resolves an attribute's label the same way the GOV.UK form builder does, i.e.
  # `helpers.label.<object_name>.<attribute>`, honouring the builder's nested
  # localisation object-name scanning so labels also resolve inside `fields_for`.
  def localised_label(attribute_name)
    key = "helpers.label.#{nested_object_name}.#{attribute_name}"

    I18n.t(key, default: nil) || I18n.t("#{key}_html", default: nil)&.html_safe
  end

  # Appends a visually hidden hint to an option's label so screen reader users
  # are told that selecting it reveals additional fields. Only injects when the
  # option's label text can be resolved, to avoid overriding the form builder's
  # own automatic label localisation with incorrect text.
  def label_with_conditional_reveal_hint(attribute_name, value, label_opts)
    label_text = label_opts[:text] || localised_option_label(attribute_name, value)
    return label_opts if label_text.blank?

    hidden_span = content_tag(:span, I18n.t('helpers.conditional_reveal_hint'),
                              class: 'govuk-visually-hidden')
    label_opts.merge(text: safe_join([label_text, hidden_span], ' '))
  end

  # Resolves an option's label the same way the GOV.UK form builder does, i.e.
  # `helpers.label.<object_name>.<attribute>_options.<value>`, honouring the
  # builder's nested localisation object-name scanning.
  def localised_option_label(attribute_name, value)
    key = "helpers.label.#{nested_object_name}.#{attribute_name}_options.#{value}"

    I18n.t(key, default: nil) || I18n.t("#{key}_html", default: nil)&.html_safe
  end

  # Mirrors the GOV.UK form builder's nested localisation object-name scanning,
  # so keys resolve for nested `fields_for` builders whose `object_name`
  # contains brackets (e.g. `parent_form[child]` -> `parent_form.child`).
  def nested_object_name
    object_name.to_s.scan(/[[:alpha:]][\w\s]*/).join('.')
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
