class IncomePayment < Payment
  store_accessor :metadata, [:before_or_after_tax]

  scope :owned_by, ->(ownership_types) { where(ownership_type: ownership_types) }
  scope :not_of_type, ->(payment_types) { where.not(payment_type: payment_types) }

  def self.employment
    where(payment_type: IncomePaymentType::EMPLOYMENT.value).order(created_at: :desc).first
  end

  def self.work_benefits
    where(payment_type: IncomePaymentType::WORK_BENEFITS.value).order(created_at: :desc).first
  end
end
