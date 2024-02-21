class AddUniquenessToIncomePaymentsBenefits < ActiveRecord::Migration[7.0]
  def change
    add_index(:income_payments, [:crime_application_id, :payment_type], unique: true)
    add_index(:income_benefits, [:crime_application_id, :payment_type], unique: true)
  end
end
