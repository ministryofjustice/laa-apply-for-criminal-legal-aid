class AddSelfAssessmentTaxBillColumnsToIncomes < ActiveRecord::Migration[7.0]
  def change
    remove_column :outgoings, :applicant_self_assessment_tax_bill, :string

    add_column :incomes, :applicant_self_assessment_tax_bill, :string
    add_column :incomes, :applicant_self_assessment_tax_bill_amount, :bigint
    add_column :incomes, :applicant_self_assessment_tax_bill_frequency, :string
  end
end
