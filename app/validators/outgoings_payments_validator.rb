class OutgoingsPaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each do |type|
      next if type == 'none'

      outgoings_payment = record.public_send(type)
      add_errors(outgoings_payment) unless outgoings_payment.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.has_no_other_outgoings.blank?
  end

  private

  def add_errors(outgoings_payment)
    outgoings_payment.errors.each do |error|
      attr_name = "#{outgoings_payment.payment_type.dasherize}-#{error.attribute}"
      record.errors.add(attr_name, error.type, message: error.message)

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        outgoings_payment.public_send(error.attribute)
      end
    end
  end
end
