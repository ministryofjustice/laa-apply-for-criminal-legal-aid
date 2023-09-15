class CreateDocumentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.timestamps
      t.datetime :deleted_at

      t.references :document_bundle, null: false, foreign_key: true, type: :uuid, index: true

      t.string :s3_object_key
      t.string :filename
      t.string :file_category
      t.string :content_type
      t.integer :file_size
    end
  end
end
