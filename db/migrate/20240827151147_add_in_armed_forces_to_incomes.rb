class AddInArmedForcesToIncomes < ActiveRecord::Migration[7.0]
  def change
    change_table :incomes, bulk: true do |t|
      t.string :client_in_armed_forces
      t.string :partner_in_armed_forces
    end
  end
end
