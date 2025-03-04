class FileUploadValidator < ActiveModel::Validator
  MIN_FILE_SIZE = 3 # KB
  MAX_FILE_SIZE = 10 # MB

  ALLOWED_CONTENT_TYPES = %w[
    application/msword
    application/pdf
    application/rtf
    application/vnd.oasis.opendocument.text
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    image/bmp
    image/jpeg
    image/png
    image/tiff
    text/csv
    text/plain
    text/rtf
  ].freeze

  attr_reader :record

  def validate(record)
    @record = record

    perform_validations
  end

  private

  # rubocop:disable Style/GuardClause
  def perform_validations
    record.errors.add(:content_type, :invalid) unless content_type_allowed?

    if record.file_size < MIN_FILE_SIZE.kilobytes
      record.errors.add(
        :file_size, :too_small, min_size: MIN_FILE_SIZE
      )
    end

    if record.file_size > MAX_FILE_SIZE.megabytes
      record.errors.add(
        :file_size, :too_big, max_size: MAX_FILE_SIZE
      )
    end
  end
  # rubocop:enable Style/GuardClause

  def content_type_allowed?
    return false unless declared_content_type_allowed? && extension_type_allowed?
    return true if detected_content_type_allowed?

    content_type_undetermined? && declared_as_text_file?
  end

  def declared_content_type_allowed?
    ALLOWED_CONTENT_TYPES.include?(record.declared_content_type)
  end

  def detected_content_type_allowed?
    ALLOWED_CONTENT_TYPES.include?(record.content_type)
  end

  def content_type_undetermined?
    record.content_type == 'application/octet-stream'
  end

  def declared_as_text_file?
    %w[text/csv text/plain].include?(record.declared_content_type)
  end

  def extension_type_allowed?
    return true if extension_type == 'application/octet-stream'

    ALLOWED_CONTENT_TYPES.include?(extension_type)
  end

  def extension_type
    Marcel::MimeType.for(name: record.filename)
  end
end
