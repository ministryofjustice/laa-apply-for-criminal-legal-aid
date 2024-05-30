class PartnerDetail < ApplicationRecord
  belongs_to :crime_application

  def self.fields
    PartnerDetail.column_names - %w[id crime_application_id updated_at created_at]
  end
end
