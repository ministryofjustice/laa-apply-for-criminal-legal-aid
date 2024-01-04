class DependantsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.dependants.each_with_index do |dependant, index|
      add_indexed_errors(dependant, index) unless dependant.valid?
    end
  end

  private

  def add_indexed_errors(dependant, index)
    dependant.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(dependant, error), ordinal: (index + 1).ordinalize_fully
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        dependant.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attr)
    "dependants-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/income/dependant_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
