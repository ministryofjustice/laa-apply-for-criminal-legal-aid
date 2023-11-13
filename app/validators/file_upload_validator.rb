class FileUploadValidator < ActiveModel::Validator
  MIN_FILE_SIZE = 0 # KB, TODO: Temporarily disable CRIMAP-207, reset to 5
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
    unless record.content_type.in?(ALLOWED_CONTENT_TYPES)
      record.errors.add(
        :content_type, :invalid
      )
    end

    if record.file_size < MIN_FILE_SIZE.kilobytes
      # TODO: Temporarily disable CRIMAP-207
      # record.errors.add(
      #   :file_size, :too_small, min_size: MIN_FILE_SIZE
      # )
    end

    if record.file_size > MAX_FILE_SIZE.megabytes
      record.errors.add(
        :file_size, :too_big, max_size: MAX_FILE_SIZE
      )
    end
  end
  # rubocop:enable Style/GuardClause
end
