class DateFieldErrorSummaryPresenter
  def initialize(form_object)
    @form_object = form_object
  end

  def formatted_error_messages
    DateFieldErrors.error_summary_messages(@form_object)
  end
end
