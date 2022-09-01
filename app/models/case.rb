class Case < ApplicationRecord
  belongs_to :crime_application

  has_many :codefendants, dependent: :destroy
  accepts_nested_attributes_for :codefendants, allow_destroy: true
end
