class CreateAmounts < ActiveRecord::Migration[7.0]
  def change
    create_table :amounts, id: :uuid do |t|
      t.integer :amount
      t.string :frequency
      t.string :type_of_amount
      t.belongs_to :crime_application
      t.jsonb :details

      t.timestamps
    end
  end
end
