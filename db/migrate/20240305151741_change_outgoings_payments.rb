class ChangeOutgoingsPayments < ActiveRecord::Migration[7.0]
def change
    change_column_null(:outgoings_payments, :amount, true, default=0)
    change_column_null(:outgoings_payments, :frequency, true, default="week")
    change_column_null(:outgoings_payments, :metadata, true, default={})
  end
end
