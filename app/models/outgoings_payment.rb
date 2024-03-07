class OutgoingsPayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type, :value_object, source: OutgoingsPaymentType
  attribute :frequency, :value_object, source: PaymentFrequencyType

  store_accessor :metadata, :details, :case_reference

  # TODO: Not sure why scope does not work instead
  def self.mortgage
    where(payment_type: OutgoingsPaymentType::MORTGAGE).order(created_at: :desc).first
  end

  def self.rent
    where(payment_type: OutgoingsPaymentType::RENT).order(created_at: :desc).first
  end

  def self.council_tax
    where(payment_type: OutgoingsPaymentType::COUNCIL_TAX).order(created_at: :desc).first
  end
end
