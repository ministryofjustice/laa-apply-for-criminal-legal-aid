# This module gets mixed in and extends the helpers already provided by
# `GOVUKDesignSystemFormBuilder::FormBuilder`. These are app-specific
# form helpers so can be coupled to application business and logic.
#
module FormBuilderHelper
  def continue_button(primary: :save_and_continue, secondary: :save_and_come_back_later)
    submit_button(primary) do
      submit_button(secondary, secondary: true, name: 'commit_draft') if secondary
    end
  end

  private

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
  end
end
