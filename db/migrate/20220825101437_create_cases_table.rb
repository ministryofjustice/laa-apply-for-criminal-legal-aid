class CreateCasesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :cases, id: :uuid do |t|
      t.string :urn
      t.references :crime_application, null: false, foreign_key: true, type: :uuid, index: { unique: true }

      t.timestamps
    end
  end
end
