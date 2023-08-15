class CreateDocumentBundlesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :document_bundles, id: :uuid do |t|
      t.timestamps
      t.datetime :submitted_at

      t.references :crime_application, null: false, foreign_key: true, type: :uuid, index: true
    end
  end
end
