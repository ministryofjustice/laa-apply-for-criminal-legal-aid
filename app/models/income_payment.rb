class IncomePayment < Payment
  include AnnualizedAmountCalculator

  store_accessor :metadata, [:before_or_after_tax]

  scope :owned_by, ->(ownership_types) { where(ownership_type: ownership_types) }
  scope :not_of_type, ->(payment_types) { where.not(payment_type: payment_types) }

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

  def self.work_benefits
    where(payment_type: IncomePaymentType::WORK_BENEFITS.value).order(created_at: :desc).first
  end

  def self.other
    where(payment_type: IncomePaymentType::OTHER.value).order(created_at: :desc).first
  end
end
