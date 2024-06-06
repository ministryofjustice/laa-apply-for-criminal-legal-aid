class AddArePartnerWagesPaidIntoAccountToSavings < ActiveRecord::Migration[7.0]
  def change
    add_column :savings, :are_partners_wages_paid_into_account, :string
  end
end
