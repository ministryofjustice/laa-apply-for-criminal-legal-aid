class RemoveExpectedEvidenceFromCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    remove_column :crime_applications, :expected_evidence, :string
  end
end
