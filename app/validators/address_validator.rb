class AddressValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    record.address.each_with_index do |(key, value), index|
      next if Property::OPTIONAL_ADDRESS_ATTRIBUTES.any? key

      record.errors.add(key, :blank, index: index + 1) if value.blank?
    end
  end
end
