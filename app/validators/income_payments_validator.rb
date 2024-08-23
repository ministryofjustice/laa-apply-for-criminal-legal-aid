class IncomePaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each_with_index do |type, index|
      next if type == 'none'

      income_payment = record.public_send(type)
      add_indexed_errors(income_payment, index) unless income_payment.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.has_no_income_payments.blank?
  end

  private

  def add_indexed_errors(income_payment, index)
    income_payment.errors.each do |error|
      attr_name = indexed_attribute(index, income_payment, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(income_payment, error)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        income_payment.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(_index, income_payment, attr)
    "#{income_payment.payment_type.dasherize}-#{attr}"
  end

  # `activemodel.errors.models.steps/income/income_payment_fieldset_form.summary.x.y`
  def error_message(obj, error)
    payment_type = I18n.t(
      obj.payment_type,
      scope: [:helpers, :label, :steps_income_income_payments_form, :types_options]
    )&.downcase!

    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models],
      payment_type: payment_type
    )
  end
end
