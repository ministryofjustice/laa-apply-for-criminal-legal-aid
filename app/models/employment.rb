class Employment < ApplicationRecord
  belongs_to :crime_application
  has_many :employments_payments, dependent: :destroy
  has_many :payments, through: :employments_payments, dependent: :destroy

  accepts_nested_attributes_for :payments

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
end
