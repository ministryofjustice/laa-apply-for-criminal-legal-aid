class CreateContactDetailsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_details, id: :uuid do |t|
      t.timestamps

      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.json :home_address, default: {}
      t.json :correspondence_address, default: {}
    end
  end
end
