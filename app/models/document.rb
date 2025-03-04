class Document < ApplicationRecord
  belongs_to :crime_application

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  validates :content_type, :filename, :file_size, presence: true, on: :create

  # Use with: `document.valid?(:criteria)`
  validates_with FileUploadValidator, on: [:criteria, :storage]

  # Use with: `document.valid?(:scan)`
  validates_with ScanValidator, on: :scan

  # In addition to the basic criteria, the object key must be
  # present to consider this document a fully valid and S3-stored one
  # Use with: `document.valid?(:storage)`
  validates :s3_object_key, presence: true, on: :storage

  # Transient attribute
  attr_accessor :tempfile, :url

  serialize :url # Allow url to be sent to UI

  scope :stored, -> { where.not(s3_object_key: nil) }
  scope :not_submitted, -> { where(submitted_at: nil) }

  def self.create_from_file(file:, crime_application:)
    create(
      crime_application: crime_application,
      filename: file.original_filename,
      content_type: Marcel::MimeType.for(file.tempfile),
      file_size: file.tempfile.size,
      tempfile: file.tempfile,
      declared_content_type: file.content_type
    )
  end
end
