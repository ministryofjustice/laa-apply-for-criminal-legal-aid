class MiscPaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each_with_index do |type, index|
      next if type == OutgoingPaymentType::NONE.to_s

      outgoing_payment = record.public_send(type)
      add_indexed_errors(outgoing_payment, index) unless outgoing_payment.valid?
    end
  end

  private

  def add_indexed_errors(outgoing_payment, index)
    outgoing_payment.errors.each do |error|
      attr_name = indexed_attribute(index, outgoing_payment, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(outgoing_payment, error)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        outgoing_payment.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(_index, outgoing_payment, attr)
    "#{outgoing_payment.payment_type.dasherize}-#{attr}"
  end

  # `activemodel.errors.models.steps/outgoings/misc_payment_fieldset_form.summary.x.y`
  def error_message(obj, error)
    payment_type = I18n.t(
      obj.payment_type,
      scope: [:helpers, :label, :steps_outgoings_misc_payments_form, :types_options]
    )

    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models],
      payment_type: payment_type
    )
  end
end
