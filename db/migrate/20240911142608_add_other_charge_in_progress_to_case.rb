class AddOtherChargeInProgressToCase < ActiveRecord::Migration[7.0]
  def change
    change_table :cases, bulk: true do |t|
      t.string :client_other_charge_in_progress
      t.string :partner_other_charge_in_progress
    end
  end
end
