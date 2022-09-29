class DateStamper
  DATE_STAMPABLE = [
    :summary_only,
    :either_way,
    :committal,
    :cc_appeal
  ].freeze

  def initialize(crime_app, case_type)
    @crime_app = crime_app
    @case_type = case_type
  end

  def call
    # TODO: what happens when we already have a date?
    if date_stampable?
      @crime_app.update(date_stamp: DateTime.now)
    end
  end

  private

  def date_stampable?
    DATE_STAMPABLE.include?(@case_type.value.to_sym) && @crime_app.date_stamp.nil?
  end
end
