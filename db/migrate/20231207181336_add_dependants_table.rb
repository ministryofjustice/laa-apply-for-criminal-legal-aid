class AddDependantsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :dependants, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.timestamps

      t.integer :age
    end
  end
end
