class ChangeColumnTypeInPropertyOwners < ActiveRecord::Migration[7.0]
  def up
    change_column :property_owners, :percentage_owned, :decimal
  end

  def down
    change_column :property_owners, :percentage_owned, :integer
  end
end
