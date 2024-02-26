class CreateCapital < ActiveRecord::Migration[7.0]
  def change
    create_table :capitals, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.string :has_premium_bonds
      t.integer :premium_bonds_total_value
      t.string :premium_bonds_holder_number

      t.timestamps
    end
  end
end
