class CreateChargesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :charges, id: :uuid do |t|
      t.timestamps

      t.references :case, type: :uuid, foreign_key: true, null: false
      t.references :offence, type: :string, foreign_key: true

      t.string :offence_name
    end
  end
end
