class Person < ApplicationRecord
  belongs_to :crime_application, touch: true
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

  def nino
    return unless has_nino == YesNoAnswer::YES.to_s

    super
  end

  def arc
    return unless has_arc == YesNoAnswer::YES.to_s

    super
  end

  def benefit_check_result
    # TODO: add comment
    return true if dwp_response == 'Yes'
    return false if %w[No Undetermined].include?(dwp_response)

    super
  end

  # def dwp_response
  #   if dwp_response.nil?
  #     return 'Yes' if benefit_check_result
  #     return 'No' if confirm_dwp_result == 'no' && means_assessment_as_benefit_evidence?
  #     return 'Undetermined' if confirm_dwp_result == 'no' && benefit_evidence_forthcoming?
  #   end
  #
  #   super
  # end

  delegate :capital, :income, to: :crime_application
end
