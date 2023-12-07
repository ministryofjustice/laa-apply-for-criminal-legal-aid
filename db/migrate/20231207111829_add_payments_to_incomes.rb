class AddPaymentsToIncomes < ActiveRecord::Migration[7.0]
  def change
    change_table :incomes do |t|
      t.string :payments, array: true, default: []
    end
  end
end
