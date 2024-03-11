class OutgoingsPayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type, :value_object, source: HousingPaymentType

  store_accessor :metadata,
                 :details,
                 :case_reference,
                 :board_amount,
                 :food_amount,
                 :payee_name,
                 :payee_relationship_to_client

  # TODO: Not sure why scope does not work instead
  def self.mortgage
    where(payment_type: OutgoingsPaymentType::MORTGAGE).order(created_at: :desc).first
  end

  def self.rent
    where(payment_type: OutgoingsPaymentType::RENT).order(created_at: :desc).first
  end
end
