class Saving < ApplicationRecord
  include TypeOfMeansAssessment

  belongs_to :crime_application

  attribute :account_balance, :pence

  scope :bank, -> { where(saving_type: SavingType::BANK.to_s) }
  scope :building_society, -> { where(saving_type: SavingType::BUILDING_SOCIETY.to_s) }
  scope :cash_isa, -> { where(saving_type: SavingType::CASH_ISA.to_s) }
  scope :national_savings_or_post_office, -> { where(saving_type: SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE.to_s) }
  scope :other, -> { where(saving_type: SavingType::OTHER.to_s) }

  def complete?
    except = %i[id crime_application_id created_at updated_at]

    except << :are_partners_wages_paid_into_account unless include_partner_in_means_assessment?

    serializable_hash(except:).values.none?(&:blank?)
  end
end
