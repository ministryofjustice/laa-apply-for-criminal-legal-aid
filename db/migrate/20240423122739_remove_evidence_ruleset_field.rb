class RemoveEvidenceRulesetField < ActiveRecord::Migration[7.0]
  def change
    remove_column :crime_applications, :evidence_ruleset
  end
end
