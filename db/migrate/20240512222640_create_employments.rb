class CreateEmployments < ActiveRecord::Migration[7.0]
  def change
    create_table :employments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.string :employer_name
      t.jsonb :address

      t.timestamps
    end
  end
end
