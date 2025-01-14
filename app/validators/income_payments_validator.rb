class IncomePaymentsValidator < BasePaymentsValidator
  def has_no_payments?
    record.has_no_income_payments.blank?
  end
end
