class ManageWithoutIncomeToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :manage_without_income, :string
    add_column :people, :manage_other_details, :string
  end
end
