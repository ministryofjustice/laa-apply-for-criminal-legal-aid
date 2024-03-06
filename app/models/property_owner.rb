class PropertyOwner < ApplicationRecord
  belongs_to :property

  default_scope { order(created_at: :asc) }

  def complete?
    values_at(
      :name,
      :relationship,
      :percentage_owned
    ).all?(&:present?)
  end
end
