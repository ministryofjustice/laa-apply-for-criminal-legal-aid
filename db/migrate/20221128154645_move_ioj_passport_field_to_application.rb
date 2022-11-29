class MoveIojPassportFieldToApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :ioj_passport, :string, array: true, default: [], null: false
    remove_column :cases, :ioj_passport, :string, array: true, default: [], null: false
  end
end
