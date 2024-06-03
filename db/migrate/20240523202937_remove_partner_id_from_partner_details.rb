class RemovePartnerIdFromPartnerDetails < ActiveRecord::Migration[7.0]
  def change
    remove_reference  :partner_details, :partner, type: :uuid
  end
end
