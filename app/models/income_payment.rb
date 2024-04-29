class IncomePayment < Payment
  def self.private_pension
    where(payment_type: IncomePaymentType::PRIVATE_PENSION.value).order(created_at: :desc).first
  end

  def self.maintenance
    where(payment_type: IncomePaymentType::MAINTENANCE.value).order(created_at: :desc).first
  end

  def self.interest_investment
    where(payment_type: IncomePaymentType::INTEREST_INVESTMENT.value).order(created_at: :desc).first
  end

  def self.rent
    where(payment_type: IncomePaymentType::RENT.value).order(created_at: :desc).first
  end

  def self.other
    where(payment_type: IncomePaymentType::OTHER.value).order(created_at: :desc).first
  end
end
