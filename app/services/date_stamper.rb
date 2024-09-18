class DateStamper
  def initialize(crime_app, case_type: 'none')
    @crime_app = crime_app
    @case_type = case_type
  end

  def call
    # TODO: Confirm provisional Date Stamp logic - 30/09/2022
    # -------------------------------------------------------
    #
    # The first time an application is changed to a “date stampable” case type,
    # a date stamp is added to the application and the use is show the date
    # stamp page.

    # If after this the use changes the case type to a non “date stampable” case
    # type, we leave the date stamp in on the application, and then just not
    # show, or use it (i.e. not show date stamp page + it will be hidden in the
    # task list).

    # At the point of submission - we can then calculate when if the date stamp
    # should apply
    # -- If case type is “date stampable” then we use the date stamp value
    # -- If case is non “date stampable” we use the submission date as the date
    #    stamp.
    return false if @crime_app.date_stamp.present?

    if @crime_app.not_means_tested? || CaseType.new(@case_type).date_stampable?
      @crime_app.date_stamp = Time.current
      @crime_app.date_stamp_checksum = date_stamp_checksum if @crime_app.date_stamp_checksum.blank?

      @crime_app.save!

      flag! if date_stamp_checksum_changed?
    else
      false
    end
  end

  private

  def date_stamp_checksum
    return nil unless @crime_app.applicant

    Digest::SHA2.new(256).hexdigest [
      @crime_app.applicant.first_name,
      @crime_app.applicant.last_name,
      @crime_app.applicant.other_names,
      @crime_app.applicant.date_of_birth,
    ].join('') # rubocop:disable Style/RedundantArgument
  end

  def date_stamp_checksum_changed?
    date_stamp_checksum != @crime_app.date_stamp_checksum
  end

  def flag!
    # TODO: Raise Event
  end
end
