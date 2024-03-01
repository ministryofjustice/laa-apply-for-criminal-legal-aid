class AddressValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    required_attributes = (record.address || {}).reject { |k, _v| Property::OPTIONAL_ADDRESS_ATTRIBUTES.any? k }
    required_attributes.each_with_index do |(key, value), index|
      record.errors.add(key, :blank, index: index + 1) if value.blank?
    end
  end
end
