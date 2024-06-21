class AddPartnerOtherWorkBenefitReceivedToIncome < ActiveRecord::Migration[7.0]
  def change
    add_column :incomes, :partner_other_work_benefit_received, :string
  end
end
