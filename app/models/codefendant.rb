class Codefendant < ApplicationRecord
  belongs_to :case, touch: true

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  def complete?
    values_at(
      :first_name,
      :last_name,
      :conflict_of_interest
    ).all?(&:present?)
  end
end
