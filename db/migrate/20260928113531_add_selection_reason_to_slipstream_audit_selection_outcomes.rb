class AddSelectionReasonToSlipstreamAuditSelectionOutcomes < ActiveRecord::Migration[7.2]
  def change
    # Nullable: the category that caused selection. Not required by status,
    # so existing records and the current selection flow remain valid.
    add_column :slipstream_audit_selection_outcomes, :selection_reason, :string

    add_check_constraint :slipstream_audit_selection_outcomes,
                         "selection_reason IN ('offence', 'age')",
                         name: 'slipstream_audit_selection_outcomes_reason_check'
  end
end
