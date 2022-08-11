class Person < ApplicationRecord
  belongs_to :crime_application
  has_many :addresses, dependent: :destroy

  def has_home_address?
    home_address.address_line_one.present?
  end

  private

  def home_address
    addresses.find_by(type: 'HomeAddress')
  end
end
