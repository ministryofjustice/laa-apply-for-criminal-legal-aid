class ChargesValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.offence_dates.each_with_index do |offence_date, index|
      add_indexed_errors(offence_date, index) unless offence_date.valid?
    end
  end

  private

  def add_indexed_errors(offence_date, index)
    offence_date.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(offence_date, error), index: index + 1
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        offence_date.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attr)
    "offence_dates-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/case/offence_date_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
