class OutgoingsPayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type
  attribute :frequency, :value_object, source: PaymentFrequencyType

  store_accessor :metadata,
                 :details,
                 :case_reference,
                 :board_amount,
                 :food_amount,
                 :payee_name,
                 :payee_relationship_to_client

  # TODO: Not sure why scope does not work instead
  def self.mortgage
    where(payment_type: OutgoingsPaymentType::MORTGAGE.value).order(created_at: :desc).first
  end

  def self.rent
    where(payment_type: OutgoingsPaymentType::RENT.value).order(created_at: :desc).first
  end

  def self.board_and_lodging
    where(payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.value).order(created_at: :desc).first
  end

  def self.council_tax
    where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.value).order(created_at: :desc).first
  end

  def self.housing_payments
    where(payment_type: OutgoingsPaymentType::HOUSING_PAYMENT_TYPES.map(&:to_s))
  end
end
