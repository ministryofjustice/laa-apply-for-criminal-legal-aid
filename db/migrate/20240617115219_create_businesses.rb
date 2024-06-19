class CreateBusinesses < ActiveRecord::Migration[7.0]
  def change
    create_table :businesses, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.string :business_type, null: false
      t.string :ownership_type, null: false, default: "applicant"

      t.timestamps
    end
  end
end
