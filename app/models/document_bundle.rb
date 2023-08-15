class DocumentBundle < ApplicationRecord
  belongs_to :crime_application
  has_many :documents, dependent: :destroy

  accepts_nested_attributes_for :documents, allow_destroy: true
end
