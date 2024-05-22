class Deduction < ApplicationRecord
  belongs_to :employment
  validates :employment_id, uniqueness: { scope: :deduction_type }
  attribute :amount, :pence
end
