module Steps
  module PaymentFieldsetValidation
    extend ActiveSupport::Concern

    def validate_frequency
      if frequency.blank?
        errors.add(:frequency, :blank, payment_type: payment_type_label)
      elsif frequencies.exclude?(frequency)
        errors.add(:frequency, :inclusion, payment_type: payment_type_label&.capitalize)
      end
    end

    def validate_amount
      if amount.blank?
        errors.add(:amount, :blank, payment_type: payment_type_label)
      elsif Type::Pence.new.serialize(amount).nil?
        errors.add(:amount, :not_a_number, payment_type: payment_type_label)
      elsif amount.to_i <= 0
        errors.add(:amount, :greater_than, payment_type: payment_type_label)
      end
    end
  end
end
