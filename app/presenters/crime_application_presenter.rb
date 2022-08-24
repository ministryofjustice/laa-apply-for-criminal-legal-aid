class CrimeApplicationPresenter < BasePresenter
  DEFAULT_CLASSES = %w[govuk-tag].freeze

  STATUSES = {
    'in_progress' => 'govuk-tag--blue',
    'submitted'   => 'govuk-tag--green',
  }.freeze

  delegate :first_name, :last_name, to: :applicant

  def start_date
    l(created_at)
  end

  def applicant_name
    "#{first_name} #{last_name}"
  end

  # this is stubbed for now will implement
  # properly when there is the means to do so
  def laa_reference
    'LAA-a1234b'
  end

  def status_tag
    tag.strong class: tag_classes do
      t!(".shared.application_status_tag.tag.#{status}")
    end
  end

  private

  def tag_classes
    DEFAULT_CLASSES | Array(STATUSES.fetch(status))
  end
end
