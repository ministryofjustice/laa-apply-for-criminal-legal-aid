class Person < ApplicationRecord
  include PersonWithFullName
  include PersonWithDob

  belongs_to :crime_application
  has_many :addresses, dependent: :destroy

  has_one :home_address, dependent: :destroy, class_name: 'HomeAddress'
  has_one :correspondence_address, dependent: :destroy, class_name: 'CorrespondenceAddress'

  has_one :income_details, foreign_key: :person_id, dependent: :destroy

  scope :with_name, -> { where.not(first_name: [nil, '']) }

  def home_address?
    home_address&.address_line_one.present?
  end

  def correspondence_address?
    correspondence_address&.address_line_one.present?
  end
end
