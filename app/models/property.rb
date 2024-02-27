class Property < ApplicationRecord
  belongs_to :crime_application

  attribute :value, :pence
  attribute :outstanding_mortgage, :pence

  def complete?
    values_at(
      :property_type,
      :house_type,
      :bedrooms,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :has_other_owners
    ).all?(&:present?)
  end
end
