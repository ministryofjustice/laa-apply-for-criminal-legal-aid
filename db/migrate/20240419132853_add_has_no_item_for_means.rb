class AddHasNoItemForMeans < ActiveRecord::Migration[7.0]
  def change
    add_column :incomes, :has_no_income_payments, :string
    add_column :incomes, :has_no_income_benefits, :string
    add_column :outgoings, :has_no_other_outgoings, :string
    add_column :capitals, :has_no_properties, :string
    add_column :capitals, :has_no_savings, :string
    add_column :capitals, :has_no_investments, :string
  end
end
