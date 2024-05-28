class RemovePartnerIdFromPartnerDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :partner_details, :partner_id
  end
end
