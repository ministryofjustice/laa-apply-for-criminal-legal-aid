module DateFieldErrors
  ERROR_SEGMENTS = {
    blank_day: :day,
    invalid_day: :day,
    blank_month: :month,
    invalid_month: :month,
    blank_year: :year,
    invalid_year: :year,
  }.freeze
  DATE_INPUT_SEGMENTS = { day: '3i', month: '2', year: '1i' }.freeze

  module_function

  def error_summary_messages(form_object)
    form_object.errors.messages.flat_map do |attribute, messages|
      summary_messages_for_attribute(form_object, attribute, messages)
    end
  end

  def joined_inline_message(form_object, attribute)
    messages = segment_error_messages(form_object, attribute).map(&:first)

    messages.join('. ') if messages.many?
  end

  def summary_messages_for_attribute(form_object, attribute, messages)
    segment_errors = segment_error_messages(form_object, attribute, messages)

    return [[attribute, messages.first]] if segment_errors.empty?

    segment_errors.map do |message, segment|
      [attribute, message, "##{date_segment_id(form_object, attribute, segment)}"]
    end
  end

  def date_segment_id(form_object, attribute, segment)
    [
      form_object.model_name.param_key,
      attribute,
      DATE_INPUT_SEGMENTS.fetch(segment),
    ].join('_')
  end

  def segment_error_messages(form_object, attribute, messages = form_object.errors.messages[attribute])
    Array(messages).zip(form_object.errors.details[attribute]).filter_map do |message, detail|
      segment = ERROR_SEGMENTS[detail[:error]]

      [message, segment] if segment
    end
  end
  private_class_method :segment_error_messages
end
