class PartnerIncomePaymentsValidator < BasePaymentsValidator
  def has_no_payments?
    record.partner_has_no_income_payments.blank?
  end
end
