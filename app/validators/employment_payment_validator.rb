class EmploymentPaymentValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record
    add_indexed_errors(record.income_payment, 1) unless record.income_payment.valid?
  end

  private

  def add_indexed_errors(payment, index)
    payment.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(payment, error), ordinal: (index + 1).ordinalize_fully
      )

      # :nocov:
      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        payment.public_send(error.attribute)
      end
      # :nocov:
    end
  end

  def indexed_attribute(index, attr)
    "income-payment-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/income/dependant_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
