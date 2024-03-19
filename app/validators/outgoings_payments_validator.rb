class OutgoingsPaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each_with_index do |type, index|
      next if type == OutgoingsPaymentType::NONE.to_s

      outgoings_payment = record.public_send(type)
      add_indexed_errors(outgoings_payment, index) unless outgoings_payment.valid?
    end

    require_type?
  end

  private

  def require_type?
    return false unless record.types.empty?

    record.errors.add(:types, :none_selected)
  end

  def add_indexed_errors(outgoings_payment, index)
    outgoings_payment.errors.each do |error|
      attr_name = indexed_attribute(index, outgoings_payment, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(outgoings_payment, error)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        outgoings_payment.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(_index, outgoings_payment, attr)
    "#{outgoings_payment.payment_type.dasherize}-#{attr}"
  end

  # `activemodel.errors.models.steps/outgoings/outgoing_payment_fieldset_form.summary.x.y`
  def error_message(obj, error)
    payment_type = I18n.t(
      obj.payment_type,
      scope: [:helpers, :label, :steps_outgoings_outgoings_payments_form, :types_options]
    )

    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models],
      payment_type: payment_type
    )
  end
end
