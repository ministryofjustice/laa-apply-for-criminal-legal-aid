class MoveApplicantSelfAssessmentTaxBillColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :incomes, :applicant_self_assessment_tax_bill, :string
    add_column :outgoings, :applicant_self_assessment_tax_bill, :string
  end
end
