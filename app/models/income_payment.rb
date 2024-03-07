class IncomePayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type, :value_object, source: IncomePaymentType
  attribute :frequency, :value_object, source: PaymentFrequencyType

  store_accessor :metadata, :details
end
