class AddHasBenefitEvidenceAttribute < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :has_benefit_evidence, :string
  end
end
