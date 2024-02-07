class CreateIncomePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :income_payments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false

      t.timestamps

      t.string :payment_type, null: false
      t.integer :amount, null: false
      t.string :frequency, null: false
      t.jsonb :metadata, default: {}, null: false
    end
  end
end
