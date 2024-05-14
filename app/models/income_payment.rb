class IncomePayment < Payment
  store_accessor :metadata,
                 [:before_or_after_tax]
  has_one :employment

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

  def self.employment
    where(payment_type: IncomePaymentType::EMPLOYMENT.value).order(created_at: :desc).first
  end

  def self.other
    where(payment_type: IncomePaymentType::OTHER.value).order(created_at: :desc).first
  end
end
