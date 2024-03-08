class CreatePropertyOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :property_owners, id: :uuid do |t|
      t.references :property, type: :uuid, foreign_key: true, null: false

      t.string :name
      t.string :relationship
      t.string :custom_relationship
      t.integer :percentage_owned
      t.timestamps
    end
  end
end
