class CreateInvestments < ActiveRecord::Migration[7.0]
  def change
    create_table :investments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.string :investment_type, null: false
      t.integer :value
      t.text :description
      t.string :ownership_type


      t.timestamps
    end

    rename_column :savings, :account_holder, :ownership_type
  end
end
