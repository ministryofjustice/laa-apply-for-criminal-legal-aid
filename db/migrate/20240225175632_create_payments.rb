class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false
      t.string :type, null: false

      t.string :payment_type, null: false
      t.integer :amount, null: false
      t.string :frequency, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps

      # A crime application can only ever have a single payment_type per payment
      t.index [:crime_application_id, :type, :payment_type], unique: true, name: "index_crime_application_payments_type_payment_type"
    end
  end
end
