class AddPartnerSelfAssessmentTaxBillColumnsToIncomes < ActiveRecord::Migration[7.0]
  def change
    add_column :incomes, :partner_self_assessment_tax_bill, :string
    add_column :incomes, :partner_self_assessment_tax_bill_amount, :bigint
    add_column :incomes, :partner_self_assessment_tax_bill_frequency, :string
  end
end
