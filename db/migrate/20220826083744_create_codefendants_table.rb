class CreateCodefendantsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :codefendants, id: :uuid do |t|
      t.references :case, type: :uuid, foreign_key: true, null: false

      t.timestamps

      t.string :first_name
      t.string :last_name
      t.string :conflict_of_interest
    end
  end
end
