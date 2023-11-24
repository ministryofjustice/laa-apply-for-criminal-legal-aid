class AddClientHaveDependantsToIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    change_table :income_details do |t|
      t.string :client_have_dependants
    end
  end
end
