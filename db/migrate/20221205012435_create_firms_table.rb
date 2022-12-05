class CreateFirmsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :firms, id: :uuid do |t|
      t.timestamps null: false

      t.string :name
      t.string :office_codes, array: true, default: [], null: false
    end
  end
end
