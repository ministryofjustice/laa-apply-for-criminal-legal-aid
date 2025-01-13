class BasePaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each do |type|
      next if type == 'none'

      payment = record.public_send(type)
      add_errors(payment) unless payment.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if has_no_payments?
  end

  # :nocov:
  def has_no_payments?
    raise 'must be implemented in subclasses'
  end
  # :nocov:

  private

  def add_errors(payment)
    payment.errors.each do |error|
      attr_name = "#{payment.payment_type.dasherize}-#{error.attribute}"
      record.errors.add(attr_name, error.type, message: error.message)

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        payment.public_send(error.attribute)
      end
    end
  end
end
