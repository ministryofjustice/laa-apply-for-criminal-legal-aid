class AddHasCaseConcludedToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :has_case_concluded, :string
    add_column :cases, :date_case_concluded, :date
  end
end
