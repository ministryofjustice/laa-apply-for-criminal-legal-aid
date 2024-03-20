class RemoveNullableOutgoingsFields < ActiveRecord::Migration[7.0]
  def up
    ::OutgoingsPayment.transaction do
      OutgoingsPayment.where('amount IS NULL OR frequency IS NULL').destroy_all

      change_column_null(:outgoings_payments, :payment_type, false)
      change_column_null(:outgoings_payments, :amount, false)
      change_column_null(:outgoings_payments, :frequency, false)
      change_column_null(:outgoings_payments, :metadata, false)
    end
  end

  def down
    change_column_null(:outgoings_payments, :amount, true, default=0)
    change_column_null(:outgoings_payments, :frequency, true, default="week")
    change_column_null(:outgoings_payments, :metadata, true, default={})
  end
end
