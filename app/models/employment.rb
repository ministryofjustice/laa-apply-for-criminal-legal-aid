class Employment < ApplicationRecord
  belongs_to :crime_application
  belongs_to :income_payment, dependent: :destroy, class_name: 'IncomePayment', foreign_key: 'payment_id', optional: true

  accepts_nested_attributes_for :income_payment

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
end
