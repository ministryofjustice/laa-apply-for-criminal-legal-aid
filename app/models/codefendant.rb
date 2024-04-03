class Codefendant < ApplicationRecord
  belongs_to :case

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  def complete?
    valid?
  end
end
