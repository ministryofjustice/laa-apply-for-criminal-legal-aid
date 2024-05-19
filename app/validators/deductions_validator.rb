class DeductionsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.types.each_with_index do |type, index|
      next if type == 'none'

      deduction = record.public_send(type)
      add_indexed_errors(deduction, index) unless deduction.valid?
    end

    return unless record.types.empty?

    record.errors.add(:base, :none_selected) if record.employment.has_no_deductions.blank?
  end

  private

  def add_indexed_errors(deduction, index)
    deduction.errors.each do |error|
      attr_name = indexed_attribute(index, deduction, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(deduction, error)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        deduction.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(_index, deduction, attr)
    "#{deduction.deduction_type.dasherize}-#{attr}"
  end

  # `activemodel.errors.models.steps/income/deduction_fieldset_form.summary.x.y`
  def error_message(obj, error)
    deduction_type = I18n.t(
      obj.deduction_type,
      scope: [:helpers, :label, :steps_income_deductions_form, :types_options]
    )

    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models],
      deduction_type: deduction_type
    )
  end
end
