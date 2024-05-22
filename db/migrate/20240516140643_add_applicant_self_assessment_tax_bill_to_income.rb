class AddApplicantSelfAssessmentTaxBillToIncome < ActiveRecord::Migration[7.0]
  def change
    add_column :incomes, :applicant_self_assessment_tax_bill, :string
  end
end
