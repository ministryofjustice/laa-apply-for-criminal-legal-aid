class AddHasSavingsToIncomes < ActiveRecord::Migration[7.0]
  def change
    change_table :incomes do |t|
      t.string :has_savings
    end
  end
end
