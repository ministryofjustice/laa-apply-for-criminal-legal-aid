class CreatePartnerDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :partner_details, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.string :relationship_to_partner
      t.string :involvement_in_case
      t.string :conflict_of_interest
      t.string :same_address_as_client

      # Not assigned until partner personal details collected
      t.uuid :partner_id, foreign_key: true, null: true, uniq: true

      t.timestamps
    end

    add_column :crime_applications, :client_relationship_status, :string
    add_column :crime_applications, :client_relationship_separated_date, :date

    # Reset People/CrimeApplication index to include type column for STI
    remove_index :people, column: [:crime_application_id], name: 'index_people_on_crime_application_id'
    add_index :people, [:type, :crime_application_id], unique: true
  end
end
