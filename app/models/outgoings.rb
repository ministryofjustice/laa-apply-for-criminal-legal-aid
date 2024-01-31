class Outgoings < ApplicationRecord
  belongs_to :crime_application

  def housing
    return nil unless housing_payment_type

    @housing ||= crime_appplication.amounts.find_or_initialize_by(
      amount_type: housing_payment_type
    ) 
  end
end
