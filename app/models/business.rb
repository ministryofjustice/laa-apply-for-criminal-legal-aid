class Business < ApplicationRecord
  belongs_to :crime_application

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode

  attribute :turnover, :amount_and_frequency
  attribute :drawings, :amount_and_frequency
  attribute :profit, :amount_and_frequency

  def complete?
    except = %i[id crime_application_id created_at updated_at]

    serializable_hash(except:).values.none?(&:blank?)
  end

  def owner
    return nil unless ownership_type

    if ownership_type == 'partner'
      crime_application.partner
    else
      crime_application.applicant
    end
  end
end
