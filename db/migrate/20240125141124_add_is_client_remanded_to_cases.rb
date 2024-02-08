class AddIsClientRemandedToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :is_client_remanded, :string
    add_column :cases, :date_client_remanded, :date
  end
end
