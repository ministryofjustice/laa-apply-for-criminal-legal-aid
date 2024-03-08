class PropertyOwner < ApplicationRecord
  belongs_to :property

  CUSTOM_RELATIONSHIP = 'custom'.freeze

  default_scope { order(created_at: :asc) }

  def complete?
    values_at(
      :name,
      :relationship,
      :percentage_owned
    ).all?(&:present?)
  end
end
