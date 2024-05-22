class Deduction < ApplicationRecord
  belongs_to :employment
  validates :employment_id, uniqueness: { scope: :deduction_type }
  attribute :amount, :pence
  enum deduction_type: { income_tax: DeductionType::INCOME_TAX.to_s,
                         national_insurance: DeductionType::NATIONAL_INSURANCE.to_s,
                         other: DeductionType::OTHER.to_s }

  def complete?
    values_at(
      :deduction_type,
      :amount,
      :frequency
    ).all?(&:present?)
  end
end
