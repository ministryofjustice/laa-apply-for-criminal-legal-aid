class UpdateAppealColumnsInCase < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :appeal_original_app_submitted, :string
    add_column :cases, :appeal_financial_circumstances_changed, :string
    add_column :cases, :appeal_reference_number, :string
    add_column :cases, :appeal_usn, :string
  end
end
