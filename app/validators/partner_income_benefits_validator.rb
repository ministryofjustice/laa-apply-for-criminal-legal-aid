class PartnerIncomeBenefitsValidator < BasePaymentsValidator
  def has_no_payments?
    record.partner_has_no_income_benefits.blank?
  end
end
