class OutgoingsPayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type, :value_object, source: HousingPaymentType

  store_accessor :metadata, :details, :case_reference

  # TODO: Not sure why scope does not work instead
  def self.mortgage
    where(payment_type: OutgoingsPaymentType::MORTGAGE).order(created_at: :desc).first
  end
end
