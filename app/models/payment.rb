class Payment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type
  attribute :frequency, :value_object, source: PaymentFrequencyType
  attribute :ownership_type

  store_accessor :metadata, :details

  scope :for_client, -> { where(ownership_type: OwnershipType::APPLICANT.to_s) }
  scope :for_partner, -> { where(ownership_type: OwnershipType::PARTNER.to_s) }

  def complete?
    values_at(:amount, :payment_type, :frequency).all?(&:present?)
  end

  def prorated_monthly # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    return amount if amount.nil? || amount.zero?

    prorated_value =
      case frequency
      when PaymentFrequencyType::WEEKLY
        (amount.value * 52) / 12
      when PaymentFrequencyType::FORTNIGHTLY
        (amount.value * 26) / 12
      when PaymentFrequencyType::FOUR_WEEKLY
        (amount.value * 13) / 12
      when PaymentFrequencyType::ANNUALLY
        amount.value / 12
      else
        amount.value
      end

    Money.new(prorated_value)
  end
end
