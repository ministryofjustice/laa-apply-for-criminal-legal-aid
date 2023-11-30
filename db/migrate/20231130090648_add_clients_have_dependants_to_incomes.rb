class AddClientsHaveDependantsToIncomes < ActiveRecord::Migration[7.0]
  def change
    change_table :incomes do |t|
      t.string :client_have_dependants
    end
  end
end
