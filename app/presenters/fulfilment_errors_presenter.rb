class FulfilmentErrorsPresenter
  FulfilmentError = Struct.new(:attribute, :message, :error, :change_path, keyword_init: true)

  attr_writer :errors

  def initialize(crime_application)
    @errors = crime_application.errors
  end

  def errors
    @errors.map { |error| build_error(error) }
  end

  private

  def build_error(error)
    FulfilmentError.new(
      attribute: error.attribute,
      message: error.message,
      error: error.details[:error],
      change_path: error.details[:change_path],
    )
  end
end
