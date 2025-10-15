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

  def segment_names
    { day: I18n.t('date.day'), month: I18n.t('date.month'), year: I18n.t('date.year') }
  end

  private

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
  end
end
