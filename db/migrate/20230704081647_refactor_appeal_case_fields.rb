class RefactorAppealCaseFields < ActiveRecord::Migration[7.0]
  def up
    rename_column :cases, :appeal_with_changes_maat_id, :appeal_lodged_date
    change_column :cases, :appeal_lodged_date, :date, using: 'NULL::date'
  end

  def down
    rename_column :cases, :appeal_lodged_date, :appeal_with_changes_maat_id
    change_column :cases, :appeal_with_changes_maat_id, :string, using: 'NULL::varchar'
  end
end
