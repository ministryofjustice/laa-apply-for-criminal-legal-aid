class CreateOutgoingsPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoings_payments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false

      t.timestamps

      t.string :payment_type, null: false
      t.integer :amount
      t.string :frequency
      t.jsonb :metadata, default: {}
      t.index [:crime_application_id, :payment_type], unique: true, name: "index_crime_application_outgoings_payment_type"
    end
  end
end
