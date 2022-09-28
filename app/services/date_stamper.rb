class DateStamper
  def initialize(crime_app, case_type)
    @crime_app = crime_app
    @case_type = case_type
  end

  def call
    if @case_type.date_stampable? && @crime_app.date_stamp.nil?
      @crime_app.update(date_stamp: DateTime.now)
    elsif !@case_type.date_stampable?
      @crime_app.update(date_stamp: nil)
      false
    else
      false
    end
  end
end
