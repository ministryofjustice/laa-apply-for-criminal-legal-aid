class CreateContactDetailsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_details, id: :uuid do |t|
      t.timestamps

      t.references :person, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.jsonb :home_address, default: {}
      t.jsonb :correspondence_address, default: {}
    end
  end
end
