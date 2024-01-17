class IncomePaymentsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.income_payments.each.with_index do |income_payment, index|
      next if income_payment.payment_type.blank?
      next if income_payment.payment_type.to_s == 'none'

      add_indexed_errors(income_payment, index) unless income_payment.valid?
    end
  end

  private

  def add_indexed_errors(income_payment, index)
    income_payment.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(income_payment, error), ordinal: (index + 1).ordinalize_fully
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        income_payment.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attr)
    "income_payments-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/income/income_payment_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
