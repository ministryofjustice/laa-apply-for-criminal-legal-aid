class IncomePaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each do |type|
      next if type == 'none'

      income_payment = record.public_send(type)
      add_errors(income_payment) unless income_payment.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.has_no_income_payments.blank?
  end

  private

  def add_errors(income_payment)
    income_payment.errors.each do |error|
      attr_name = "#{income_payment.payment_type.dasherize}-#{error.attribute}"
      record.errors.add(attr_name, error.type, message: error.message)

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        income_payment.public_send(error.attribute)
      end
    end
  end
end
