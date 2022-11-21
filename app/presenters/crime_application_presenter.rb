class CrimeApplicationPresenter < BasePresenter
  def initialize(object)
    super(
      Adapters::BaseApplication.build(object)
    )
  end

  def applicant_dob
    l(applicant.date_of_birth)
  end

  def applicant_name
    "#{applicant.first_name} #{applicant.last_name}"
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
end
