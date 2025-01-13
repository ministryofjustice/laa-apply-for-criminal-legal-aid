class IncomeBenefitsValidator < BasePaymentsValidator
  def has_no_payments?
    record.has_no_income_benefits.blank?
  end
end
