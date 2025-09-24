class Investment < ApplicationRecord
  belongs_to :crime_application, touch: true

  attribute :value, :pence

  scope :bond, -> { where(investment_type: InvestmentType::BOND.to_s) }
  scope :pep, -> { where(investment_type: InvestmentType::PEP.to_s) }
  scope :share, -> { where(investment_type: InvestmentType::SHARE.to_s) }
  scope :share_isa, -> { where(investment_type: InvestmentType::SHARE_ISA.to_s) }
  scope :stock, -> { where(investment_type: InvestmentType::STOCK.to_s) }
  scope :unit_trust, -> { where(investment_type: InvestmentType::UNIT_TRUST.to_s) }
  scope :other, -> { where(investment_type: InvestmentType::OTHER.to_s) }

  def complete?
    except = %i[id crime_application_id created_at updated_at]
    serializable_hash(except:).values.none?(&:blank?)
  end
end
