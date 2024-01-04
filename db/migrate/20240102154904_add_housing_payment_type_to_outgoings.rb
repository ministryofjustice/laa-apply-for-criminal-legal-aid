class AddHousingPaymentTypeToOutgoings < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoings, :housing_payment_type, :string
  end
end
