class CreateIncomePaymentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :income_payments, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false

      t.timestamps

      t.string :type
      t.integer :amount
      t.string :frequency
      t.string :details
    end
  end
end
