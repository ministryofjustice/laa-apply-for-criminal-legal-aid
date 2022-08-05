class Person < ApplicationRecord
  belongs_to :crime_application
  has_many :addresses, dependent: :destroy
end
