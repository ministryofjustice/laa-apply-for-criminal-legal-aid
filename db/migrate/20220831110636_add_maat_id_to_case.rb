class AddMaatIdToCase < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :previous_maat_id, :string
    add_column :cases, :cc_appeal_fin_change_details, :text
  end
end
