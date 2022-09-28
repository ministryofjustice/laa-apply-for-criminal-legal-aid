class DateStamp
  def initialize(form_object)
		@crime_app = form_object.crime_application
		@case_type = form_object.case_type
  end

	def call
		if @case_type.date_stampable? && @crime_app.date_stamp.nil?
			update_stamp(DateTime.now)
		elsif !@case_type.date_stampable?
			update_stamp(nil)
			false
		else
			false
		end
	end

	private

	def update_stamp(date_time)
		@crime_app.date_stamp = date_time
		@crime_app.save
	end
end