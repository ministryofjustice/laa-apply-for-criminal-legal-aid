class AddClientOwnsPropertyToIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    change_table :income_details do |t|
      t.string :client_owns_property
    end
  end
end
