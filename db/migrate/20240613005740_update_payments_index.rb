class UpdatePaymentsIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :payments, column: [:crime_application_id, :type, :payment_type], name: 'index_payments_crime_application_id_and_payment_type'
    add_index :payments, [:crime_application_id, :type, :payment_type, :ownership_type], unique: true, name: 'index_payments_unique_payment_type'
  end
end
