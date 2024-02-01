class AddIsPreorderWorkClaimedToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :is_preorder_work_claimed, :string
    add_column :cases, :preorder_work_date, :date
    add_column :cases, :preorder_work_details, :text
  end
end
