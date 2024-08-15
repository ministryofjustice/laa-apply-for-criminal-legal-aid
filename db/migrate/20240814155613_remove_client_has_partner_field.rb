class RemoveClientHasPartnerField < ActiveRecord::Migration[7.0]
  def up
    remove_column :crime_applications, :client_has_partner
  end

  def down
    add_column :crime_applications, :client_has_partner, :string

    PartnerDetail.all.pluck(:crime_application_id, :has_partner).each do |id, value|
      CrimeApplication.find_by(id:)&.update(client_has_partner: value)
    end
  end
end
