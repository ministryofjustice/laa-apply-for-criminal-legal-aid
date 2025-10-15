class Employment < ApplicationRecord
  include AnnualizedAmountCalculator

  belongs_to :crime_application, touch: true

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  has_many :deductions, -> { order(deduction_type: :asc) }, inverse_of: :employment, dependent: :destroy do
    def complete
      select(&:complete?)
    end
  end

  attribute :amount, :pence

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
  store_accessor :metadata, [:before_or_after_tax]

  OPTIONAL_ADDRESS_ATTRIBUTES = %w[address_line_two].freeze
  REQUIRED_ADDRESS_ATTRIBUTES = Address::ADDRESS_ATTRIBUTES.map(&:to_s).reject { |a| a.in? OPTIONAL_ADDRESS_ATTRIBUTES }
  REQUIRED_ATTRIBUTES = [
    :ownership_type,
    :employer_name,
    :job_title,
    :amount,
    :frequency,
    :before_or_after_tax
  ].freeze

  def complete?
    values_at(*REQUIRED_ATTRIBUTES).all?(&:present?) &&
      address_complete? &&
      deductions_complete?
  end

  def address_complete?
    address.present? && address.values_at(*REQUIRED_ADDRESS_ATTRIBUTES.map(&:to_s)).all?(&:present?)
  end

  def deductions_complete?
    return true if has_no_deductions == YesNoAnswer::YES.to_s

    deductions.present? && deductions.all?(&:complete?)
  end
end
