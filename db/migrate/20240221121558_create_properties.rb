class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties, id: :uuid do |t|
      t.references :person, type: :uuid, foreign_key: true, null: false

      t.string :property_type, null: false
      t.string :house_type
      t.integer :size_in_acres
      t.string :usage
      t.integer :bedrooms
      t.integer :value
      t.integer :outstanding_mortgage
      t.integer :percentage_applicant_owned
      t.integer :percentage_partner_owned
      t.string :is_home_address
      t.string :has_other_owners
      t.json :address

      t.timestamps
    end
  end
end
