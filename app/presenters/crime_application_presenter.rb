class CrimeApplicationPresenter < BasePresenter
  delegate :first_name, :last_name, :date_of_birth, to: :applicant
  delegate :case_type, to: :case, allow_nil: true

  # To build RESTful urls with route helpers, even
  # for applications coming from the datastore
  def to_param
    id
  end

  def start_date
    l(created_at)
  end

  def applicant_dob
    l(date_of_birth)
  end

  def applicant_name
    "#{first_name} #{last_name}"
  end

  def applicant?
    applicant.present?
  end

  # - If case type is “date stampable”, we use the date stamp value
  # - If case type is non “date stampable”, and the application is submitted,
  #   we use the submission date as the date stamp
  #
  def interim_date_stamp
    date = if date_stampable?
             date_stamp
           elsif submitted?
             submitted_at
           end

    l(date, format: :datetime) if date
  end

  def date_stampable?
    CaseType.new(case_type.to_s).date_stampable?
  end

  # Keep this wrapper method in case we retract from
  # using sequence USN to use any other ID/reference
  def laa_reference
    usn
  end
end
