# This module gets mixed in and extends the helpers already provided by
# `GOVUKDesignSystemFormBuilder::FormBuilder`. These are app-specific
# form helpers so can be coupled to application business and logic.
#
module FormBuilderHelper
  def continue_button
    submit_button(:save_and_continue) do
      submit_button(:save_and_come_back_later, secondary: true, name: 'commit_draft') if show_secondary_button?
    end
  end

  private

  # The `save and come back later` might not always be needed,
  # this method can have logic for show/hide.
  # :nocov:
  def show_secondary_button?
    true
  end
  # :nocov:

  def submit_button(i18n_key, opts = {}, &block)
    govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
  end
end
