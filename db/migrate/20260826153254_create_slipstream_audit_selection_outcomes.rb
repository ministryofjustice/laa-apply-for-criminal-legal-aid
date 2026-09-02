class CreateSlipstreamAuditSelectionOutcomes < ActiveRecord::Migration[7.2]
  def change
    create_table :slipstream_audit_selection_outcomes, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.references :crime_application, null: false, foreign_key: true, type: :uuid,
                                       index: { unique: true, name: 'idx_slipstream_outcomes_app' }
      # The percentage chance of selection: 20 means 20%.
      t.integer :sample_rate, null: false
      t.datetime :sampled_at, null: false
      t.string :status, null: false
      t.datetime :status_determined_at, null: false
      t.timestamps

      t.check_constraint "status IN ('not_selected', 'selected', 'confirmed', 'withdrawn')",
                         name: 'slipstream_audit_selection_outcomes_status_check'
      t.check_constraint 'sample_rate BETWEEN 1 AND 100', name: 'slipstream_outcomes_sample_rate_check'
    end
  end
end
