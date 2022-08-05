class Person < ApplicationRecord
  belongs_to :crime_application
  has_many :addresses, dependent: :destroy
  has_one :contact_details, dependent: :destroy
end
