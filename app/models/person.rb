class Person < ApplicationRecord
  belongs_to :crime_application
  has_one :contact_details, dependent: :destroy
end
