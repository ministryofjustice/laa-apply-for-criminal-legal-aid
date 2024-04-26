class IncomePayment < Payment
  def self.private_pension
    where(payment_type: IncomePaymentType::PRIVATE_PENSION.value).order(created_at: :desc).first
  end
end
