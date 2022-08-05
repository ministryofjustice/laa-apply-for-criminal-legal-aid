class DropContactDetailsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :contact_details
  end

  def down
    create_table :contact_details, id: :uuid
  end
end
