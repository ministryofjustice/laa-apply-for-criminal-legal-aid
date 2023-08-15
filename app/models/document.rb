class Document < ApplicationRecord
  belongs_to :document_bundle

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }
end
