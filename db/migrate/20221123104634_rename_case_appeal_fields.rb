class RenameCaseAppealFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :cases, :cc_appeal_maat_id, :appeal_maat_id
    rename_column :cases, :cc_appeal_fin_change_maat_id, :appeal_with_changes_maat_id
    rename_column :cases, :cc_appeal_fin_change_details, :appeal_with_changes_details
  end
end
