class ChangeColumnAddressInProperties < ActiveRecord::Migration[7.0]
  def up
    change_column(:properties, :address, :jsonb)
  end

  def down
    change_column(:properties, :address, :json)
  end
end
