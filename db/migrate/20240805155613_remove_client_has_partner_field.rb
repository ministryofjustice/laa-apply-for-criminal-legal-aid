class RemoveClientHasPartnerField < ActiveRecord::Migration[7.0]
  def up
    remove_column :crime_applications, :client_has_partner
  end

  def down
    add_column :crime_applications, :client_has_partner
  end
end
