class OutgoingPayment < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  store_accessor :metadata, :case_reference
end
