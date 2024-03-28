class ChangePenceToBigInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :capitals, :premium_bonds_total_value, :bigint
    change_column :capitals, :trust_fund_amount_held, :bigint
    change_column :capitals, :trust_fund_yearly_dividend, :bigint
    change_column :payments, :amount, :bigint
    change_column :investments, :value, :bigint
    change_column :national_savings_certificates, :value, :bigint
    change_column :properties, :outstanding_mortgage, :bigint
    change_column :properties, :value, :bigint
    change_column :savings, :account_balance, :bigint
  end
end
