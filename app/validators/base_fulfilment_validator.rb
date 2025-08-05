class BaseFulfilmentValidator < ActiveModel::Validator
  include Routing

  attr_reader :record

  def validate(record)
    @record = record

    errors = perform_validations
    add_errors(errors)
  end

  # Used by the `Routing` module to build the urls
  def default_url_options
    super.merge(id: record)
  end

  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  # :nocov:
  def perform_validations
    raise 'implement in subclasses'
  end
  # :nocov:

  def evidence_present?
    record.documents.stored.any?
  end

  def add_errors(errors)
    errors.each do |(attr, type, opts)|
      record.errors.add(attr, type, **opts)
    end
  end
end
