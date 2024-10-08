class RemoveClientHasPartnerField < ActiveRecord::Migration[7.0]
  def up
    remove_column :crime_applications, :client_has_partner
    change_column_default :partner_details, :has_partner, nil
    change_column_null :partner_details, :has_partner, true
  end

  def down
    add_column :crime_applications, :client_has_partner, :string
    change_column_default :partner_details, :has_partner, 'no'
    change_column_null :partner_details, :has_partner, false

    PartnerDetail.all.pluck(:crime_application_id, :has_partner).each do |id, value|
      CrimeApplication.find_by(id:)&.update(client_has_partner: value)
    end
  end
end
