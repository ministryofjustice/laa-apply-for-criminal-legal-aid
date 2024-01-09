class Payment < ApplicationRecord
  belongs_to :crime_application

  def type
  end

  def amount
  end

  def frequency
  end

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }
end
