class Investment < ApplicationRecord
  belongs_to :crime_application

  attribute :value, :pence

  scope :for_client, -> { where(ownership_type: OwnershipType::APPLICANT.to_s) }
  scope :for_partner, -> { where(ownership_type: OwnershipType::PARTNER.to_s) }

  def complete?
    except = %i[id crime_application_id created_at updated_at]
    serializable_hash(except:).values.none?(&:blank?)
  end
end
