class CreateSavings < ActiveRecord::Migration[7.0]
  def change
    create_table :savings, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false

      t.string :saving_type, null: false
      t.string :provider_name
      t.string :sort_code
      t.string :account_number
      t.integer :account_balance
      t.string :is_overdrawn
      t.string :are_wages_paid_into_account
      t.string :account_holder

      t.timestamps
    end
  end
end
