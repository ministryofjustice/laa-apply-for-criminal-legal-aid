class AddExpectedEvidenceField < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :expected_evidence, :string, array: true, default: []
  end
end
