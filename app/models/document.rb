class Document < ApplicationRecord
  belongs_to :crime_application

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  # Use with: `document.valid?(:criteria)`
  validates_with FileUploadValidator, on: [:criteria, :storage]

  # Use with: `document.valid?(:scan)`
  validates_with ScanValidator, on: :scan

  # In addition to the basic criteria, the object key must be
  # present to consider this document a fully valid and S3-stored one
  # Use with: `document.valid?(:storage)`
  validates :s3_object_key, presence: true, on: :storage

  # Transient attribute
  attr_accessor :tempfile

  scope :stored, -> { where.not(s3_object_key: nil) }
  scope :not_submitted, -> { where(submitted_at: nil) }
  scope :post_submission_evidence, lambda {
    where(application_type: ApplicationType::POST_SUBMISSION_EVIDENCE.to_s).where.not(s3_object_key: nil)
  }
  scope :supporting_evidence, lambda {
    where.not(application_type: ApplicationType::POST_SUBMISSION_EVIDENCE.to_s).where.not(s3_object_key: nil)
  }

  def self.create_from_file(file:, crime_application:)
    create(
      crime_application: crime_application,
      filename: file.original_filename,
      content_type: file.content_type,
      file_size: file.tempfile.size,
      tempfile: file.tempfile,
      application_type: crime_application.application_type
    )
  end
end
