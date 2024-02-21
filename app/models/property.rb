class Property < ApplicationRecord
  belongs_to :person

  def complete?
    values_at(
      :property_type,
      :house_type,
      :bedrooms,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :is_home_address,
      :has_other_owners
    ).all?(&:present?)
  end
end
