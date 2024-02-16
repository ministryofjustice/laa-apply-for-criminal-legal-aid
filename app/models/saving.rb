class Saving < ApplicationRecord
  belongs_to :crime_application

  attribute :account_balance, :pence

  def complete?
    # TODO: add other required attributes
    saving_type.present? && account_holder.present?
  end
end
