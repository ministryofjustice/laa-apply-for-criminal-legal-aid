class Deduction < ApplicationRecord
  belongs_to :employment
  validates :amount, numericality: { greater_than: 0 }
  validates :frequency, presence: true, inclusion: { in: PaymentFrequencyType.values.map(&:to_s) }
  validates :deduction_type, presence: true, inclusion: { in: DeductionType.values.map(&:to_s) }
  validates :employment_id, uniqueness: { scope: :deduction_type }
  attribute :amount, :pence
end
