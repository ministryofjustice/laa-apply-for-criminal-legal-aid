class NationalSavingsCertificate < ApplicationRecord
  belongs_to :crime_application

  attribute :value, :pence

  def complete?
    except = %i[id crime_application_id created_at updated_at]
    serializable_hash(except:).values.none?(&:blank?)
  end
end
