class PartnerDetail < ApplicationRecord
  belongs_to :crime_application
  has_one :partner, dependent: :destroy
end
