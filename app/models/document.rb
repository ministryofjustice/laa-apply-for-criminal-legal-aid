class Document < ApplicationRecord
  belongs_to :document_bundle

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  # Use with: `document.valid?(:criteria)`
  validates_with FileUploadValidator, on: [:criteria, :storage]

  # In addition to the basic criteria, the object key must be
  # present to consider this document a fully valid and S3-stored one
  # Use with: `document.valid?(:storage)`
  validates :s3_object_key, presence: true, on: :storage

  # Transient attribute
  attr_accessor :tempfile

  def self.create_from_file(file:, bundle:)
    create(
      document_bundle: bundle,
      filename: file.original_filename,
      content_type: file.content_type,
      file_size: file.tempfile.size,
      tempfile: file.tempfile,
    )
  end
end
