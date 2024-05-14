class CreateEmploymentsPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :employments_payments, id: :uuid do |t|
      t.references :employment, null: false, foreign_key: true, type: :uuid
      t.references :payment, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
