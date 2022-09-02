class AddHasCodefendantsToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :has_codefendants, :string
  end
end
