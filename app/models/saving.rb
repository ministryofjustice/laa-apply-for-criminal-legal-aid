class Saving < ApplicationRecord
  include TypeOfMeansAssessment

  belongs_to :crime_application

  attribute :account_balance, :pence

  scope :for_client, -> { where(ownership_type: OwnershipType::APPLICANT.to_s) }
  scope :for_partner, -> { where(ownership_type: OwnershipType::PARTNER.to_s) }

  def complete?
    except = %i[id crime_application_id created_at updated_at]

    except << :are_partners_wages_paid_into_account unless include_partner_in_means_assessment?

    serializable_hash(except:).values.none?(&:blank?)
  end
end
