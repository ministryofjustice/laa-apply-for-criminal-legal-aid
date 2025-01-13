module Steps
  module PaymentFieldsetValidation
    extend ActiveSupport::Concern

    def validate_frequency
      errors.add(:frequency, :blank, payment_type: payment_type_label) if frequency.blank?
      return unless frequencies.exclude?(frequency)

      errors.add(:frequency, :inclusion,
                 payment_type: payment_type_label&.capitalize)
    end

    def validate_amount
      errors.add(:amount, :blank, payment_type: payment_type_label) if amount.blank?
      errors.add(:amount, :not_a_number, payment_type: payment_type_label) if Type::Pence.new.serialize(amount).nil?
      errors.add(:amount, :greater_than, payment_type: payment_type_label) if amount.to_i <= 0
    end
  end
end
