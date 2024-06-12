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

  def applicant?
    is_a? Applicant
  end

  def partner?
    is_a? Partner
  end

  def over_18_at_date_stamp?
    datum = crime_application&.date_stamp || Time.zone.now

    datum.in_time_zone('London').to_date - 18.years >= date_of_birth
  end
end
