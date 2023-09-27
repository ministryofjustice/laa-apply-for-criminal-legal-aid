class ApplicationFulfilmentValidator < ActiveModel::Validator
  include Routing

  attr_reader :record

  def validate(record)
    @record = record

    errors = perform_validations
    add_errors(errors)
  end

  # Used by the `Routing` module to build the urls
  def default_url_options
    { id: record }
  end

  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  def perform_validations
    errors = []

    unless Passporting::MeansPassporter.new(record).call
      errors << [
        :means_passport, :blank, { change_path: edit_steps_client_details_path }
      ]
    end

    unless Passporting::IojPassporter.new(record).call || ioj_present?
      errors << [
        :ioj_passport, :blank, { change_path: edit_steps_case_ioj_path }
      ]
    end

    errors
  end

  def ioj_present?
    record.ioj.present? && record.ioj.types.any?
  end

  def add_errors(errors)
    errors.each do |(attr, type, opts)|
      record.errors.add(attr, type, **opts)
    end
  end
end
