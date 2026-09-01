class SlipstreamAuditSelectionOutcome < ApplicationRecord
  belongs_to :crime_application

  # An eligible application is sampled once. A selected outcome is subsequently
  # confirmed or withdrawn based on the checks performed at submission.
  enum :status, {
    not_selected: 'not_selected',
    selected: 'selected',
    confirmed: 'confirmed',
    withdrawn: 'withdrawn'
  }

  # The percentage chance of selection: a sample rate of 20 means 20%.
  validates :sample_rate,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :sampled_at, :status, :status_determined_at, presence: true
end
