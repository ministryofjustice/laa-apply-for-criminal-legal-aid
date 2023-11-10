class CreateIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :income_details, id: :uuid do |t|
      t.uuid :person_id, null: false
      t.string :income_above_threshold

      t.timestamps
    end

    add_index :income_details, :person_id
    add_foreign_key :income_details, :people, column: :person_id
  end
end
