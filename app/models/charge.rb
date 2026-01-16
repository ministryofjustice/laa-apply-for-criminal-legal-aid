class Charge < ApplicationRecord
  belongs_to :case, touch: true

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

  def valid_dates?
    offence_dates.any? && offence_dates.all?(&:date_from)
  end
end
