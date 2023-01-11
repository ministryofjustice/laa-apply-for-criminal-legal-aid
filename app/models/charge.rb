class Charge < ApplicationRecord
  belongs_to :case

  has_many :offence_dates, dependent: :destroy
  accepts_nested_attributes_for :offence_dates, allow_destroy: true

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  composed_of :offence, mapping: %i[offence_name name],
              constructor: :find_by_name, allow_nil: true

  delegate :offence_class, :offence_type,
           to: :offence, allow_nil: true

  def complete?
    offence_name.present? && valid_dates?
  end

  # NOTE: we use `pluck` in several places instead of ActiveRecord,
  # as to make these methods compatible with JSON responses received
  # from the datastore (submitted applications).
  def valid_dates?
    dates = offence_dates.pluck(:date_from)
    dates.any? && dates.all?
  end
end
