class Person < ApplicationRecord
  belongs_to :crime_application
  has_many :addresses, dependent: :destroy

  has_one :home_address, dependent: :destroy, class_name: 'HomeAddress'

  scope :with_name, -> { where.not(first_name: [nil, '']) }

  def home_address?
    home_address.address_line_one.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
