class CreateOutgoings < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoings, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }
      
      t.string :outgoings_more_than_income
      t.string :how_manage

      t.timestamps
    end
  end
end
