class Payment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  attribute :payment_type
  attribute :frequency, :value_object, source: PaymentFrequencyType

  store_accessor :metadata, :details

  def complete?
    values_at(:amount, :payment_type, :frequency).all?(&:present?)
  end
end
