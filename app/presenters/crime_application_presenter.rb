class CrimeApplicationPresenter < BasePresenter
  DEFAULT_CLASSES = %w[govuk-tag].freeze

  STATUSES = {
    'in_progress' => 'govuk-tag--blue',
    'submitted'   => 'govuk-tag--green',
  }.freeze

  delegate :first_name, :last_name, :date_of_birth, to: :applicant
  delegate :case_type, to: :case, allow_nil: true

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

  def submitted_date
    l(submitted_at, format: :datetime) if submitted_at
  end

  # - If case type is “date stampable”, we use the date stamp value
  # - If case type is non “date stampable”, we use the submission date as the date stamp
  def application_date_stamp
    date = date_stampable? ? date_stamp : submitted_at
    l(date, format: :datetime) if date
  end

  def date_stampable?
    CaseType.new(case_type.to_s).date_stampable?
  end

  # this is stubbed for now will implement
  # properly when there is the means to do so
  def laa_reference
    ['LAA', id[0..5]].join('-')
  end

  def status_tag
    tag.strong class: tag_classes do
      t!(".crime_applications.index.status.#{status}")
    end
  end

  private

  def tag_classes
    DEFAULT_CLASSES | Array(STATUSES.fetch(status))
  end
end
