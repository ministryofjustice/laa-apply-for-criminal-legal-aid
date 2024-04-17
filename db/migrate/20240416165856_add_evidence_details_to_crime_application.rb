class AddEvidenceDetailsToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    change_table :crime_applications do |t|
      t.jsonb :evidence_ruleset, default: []
      t.jsonb :evidence_prompts, default: []
      t.datetime :evidence_last_run_at
    end
  end
end
