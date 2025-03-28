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

  def can_be_withdrawn?
    initial? && !reviewed?
  end

  # This is used in the task list (applications in progress)
  #
  # - If case type is “date stampable”, we use the date stamp value
  # - If case type is non “date stampable”, we just return `nil`
  #
  # We have to check if it is date stampable, instead of blindly
  # using `date_stamp` value, as provider might change case types
  #
  def interim_date_stamp
    l(date_stamp, format: :datetime) if date_stampable? && date_stamp.present?
  end

  def date_stampable?
    CaseType.new(case_type.to_s).date_stampable?
  end

  def draft
    CrimeApplication.find_by(parent_id: id)
  end
end
