class Employment < ApplicationRecord
  belongs_to :crime_application

  has_many :deductions, dependent: :destroy

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
  store_accessor :metadata, [:before_or_after_tax]
end
