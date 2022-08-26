class Case < ApplicationRecord
  belongs_to :crime_application
  has_many :codefendants, dependent: :destroy
end
