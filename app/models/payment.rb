class Payment < ApplicationRecord
  include AnnualizedAmountCalculator

  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type
  attribute :frequency, :value_object, source: PaymentFrequencyType
  attribute :ownership_type

  store_accessor :metadata, :details

  scope :for_client, -> { where(ownership_type: OwnershipType::APPLICANT.to_s) }
  scope :for_partner, -> { where(ownership_type: OwnershipType::PARTNER.to_s) }
  scope :completed, -> { where.not(payment_type: '').where.not(frequency: '') }

  def complete?
    values_at(:amount, :payment_type, :frequency).all?(&:present?)
  end

  def prorated_monthly
    return amount if amount.nil? || amount.zero?

    Money.new(annualized_amount.value / 12)
  end
end
