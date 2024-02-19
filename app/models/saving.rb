class Saving < ApplicationRecord
  belongs_to :crime_application

  attribute :account_balance, :pence

  def complete?
    !attributes.values.any?(&:blank?)
  end
end
