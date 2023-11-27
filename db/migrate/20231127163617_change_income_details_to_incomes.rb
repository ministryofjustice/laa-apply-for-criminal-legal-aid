class ChangeIncomeDetailsToIncomes < ActiveRecord::Migration[7.0]
  def change
    rename_table :income_details, :incomes
  end
end
