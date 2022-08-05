class AddAddressesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.timestamps
      t.string :type, null: false

      t.references :person, type: :uuid, foreign_key: true, null: false, index: true

      t.string :address_line_one
      t.string :address_line_two
      t.string :city
      t.string :country
      t.string :postcode
    end

    add_index :addresses, [:type, :person_id], unique: true
  end
end
