class Person < ApplicationRecord
  include PersonWithDob

  belongs_to :crime_application
  has_many :addresses, dependent: :destroy

  has_one :home_address, dependent: :destroy, class_name: 'HomeAddress'
  has_one :correspondence_address, dependent: :destroy, class_name: 'CorrespondenceAddress'

  scope :with_name, -> { where.not(first_name: [nil, '']) }

  def home_address?
    home_address&.address_line_one.present?
  end

  def correspondence_address?
    correspondence_address&.address_line_one.present?
  end

  def has_passporting_benefit?
    BenefitType.passporting.map(&:value).include?(benefit_type&.to_sym)
  end

  def over_18_at_date_stamp?
    datum = crime_application&.date_stamp || Time.zone.now

    Person.over_18?(datum, date_of_birth)
  end

  def under_18_at_date_stamp?
    !over_18_at_date_stamp?
  end

  def self.over_18?(from_date, date_of_birth)
    from_date.in_time_zone('London').to_date - 18.years >= date_of_birth
  end

  def self.under_18?(from_date, date_of_birth)
    !over_18?(from_date, date_of_birth)
  end

  def nino
    return unless has_nino == YesNoAnswer::YES.to_s

    super
  end

  def arc
    return unless has_arc == YesNoAnswer::YES.to_s

    super
  end

  delegate :capital, :income, to: :crime_application
end
