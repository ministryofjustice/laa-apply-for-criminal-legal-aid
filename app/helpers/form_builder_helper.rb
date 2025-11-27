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
    govuk_date_field(attribute_name, segments:, segment_names:, **opts, &block)
  end

  private

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
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
