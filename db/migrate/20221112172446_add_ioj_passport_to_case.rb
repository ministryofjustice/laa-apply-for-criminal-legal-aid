class AddIojPassportToCase < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :ioj_passport, :string, array: true, default: []
  end
end
