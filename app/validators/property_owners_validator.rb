class PropertyOwnersValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    record.property_owners.each_with_index do |property_owner, index|
      add_indexed_errors(property_owner, index) unless property_owner.valid?
    end
  end

  private

  def add_indexed_errors(property_owner, index)
    property_owner.errors.each do |error|
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(property_owner, error), index: index + 1
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        property_owner.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attr)
    "property_owners-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/capital/property_owner_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end
end
