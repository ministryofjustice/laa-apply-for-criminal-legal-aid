class Income < ApplicationRecord
  belongs_to :crime_application
  delegate :case, to: :crime_application
end
