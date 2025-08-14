class CreateDeletionLogsTable < ActiveRecord::Migration[7.2]
  def change
    create_table :deletion_logs, id: :uuid do |t|
      t.timestamps

      t.string :record_id, null: false
      t.string :record_type, null: false
      t.string :business_reference
      t.string :deleted_by, null: false
      t.string :reason, null: false
    end
  end
end
