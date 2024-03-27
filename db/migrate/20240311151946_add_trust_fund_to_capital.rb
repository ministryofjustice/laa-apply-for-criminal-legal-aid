class AddTrustFundToCapital < ActiveRecord::Migration[7.0]
  def change
    add_column :capitals, :will_benefit_from_trust_fund, :string
    add_column :capitals, :trust_fund_amount_held, :integer
    add_column :capitals, :trust_fund_yearly_dividend, :integer
  end
end
