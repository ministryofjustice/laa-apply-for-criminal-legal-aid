class AddClientHasPartnerField < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :client_has_partner, :string
  end
end
