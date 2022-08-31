class CodefendantsValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.codefendants.each.with_index do |codefendant, index|
      add_indexed_errors(codefendant, index) unless codefendant.valid?
    end
  end

  private

  def add_indexed_errors(codefendant, index)
    codefendant.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(codefendant, error), index: index + 1
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        codefendant.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attr)
    "codefendants-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/case/codefendant_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
