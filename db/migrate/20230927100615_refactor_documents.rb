class RefactorDocuments < ActiveRecord::Migration[7.0]
  def up
    drop_table :documents
    drop_table :document_bundles

    create_table :documents, id: :uuid do |t|
      t.timestamps

      t.datetime :submitted_at
      t.datetime :deleted_at

      t.references :crime_application, null: false, foreign_key: true, type: :uuid, index: true
      t.jsonb :annotations, null: false, default: {}

      t.string :s3_object_key
      t.string :filename
      t.string :file_category
      t.string :content_type
      t.integer :file_size
    end
  end

  def down
    # Just so it can perform the down in the previous migrations
    # although note the code would have changed dramatically
    create_table :document_bundles, id: :uuid
  end
end
