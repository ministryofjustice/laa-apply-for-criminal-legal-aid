class PaymentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.amount.blank?
      record.errors.add attribute, :amount_blank
      record.public_send(attribute).errors.add :amount, :amount_blank
    end

    return if value.frequency.to_s.present?

    record.errors.add attribute, :frequency_blank
    record.public_send(attribute).errors.add :frequency, :frequency_blank
  end
end
